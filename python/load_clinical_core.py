"""
load_clinical_core.py
---------------------
ETL Stage 2.3 - Core Clinical Layer

Part A: patients.csv   -> PATIENT
Part B: encounters.csv -> PAT_ENC + PAT_ENC_HSP

Builds and persists pat_id_map and csn_id_map.

Project: Epic Clarity-Style Clinical Reporting & Analytics Platform
Phase:   2 - ETL  |  Stage: 2.3 - Core clinical
"""

import os
import json
import pandas as pd
from sqlalchemy import create_engine

# ----------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------
SERVER   = "PRAKASH"
DATABASE = "EpicClaritySim"
DRIVER   = "ODBC Driver 17 for SQL Server"

CONNECTION_STRING = (
    f"mssql+pyodbc://@{SERVER}/{DATABASE}"
    f"?driver={DRIVER.replace(' ', '+')}"
    f"&trusted_connection=yes"
)

SYNTHEA_DIR = r"C:\Projects\epic-clarity\data\raw\synthea"
MAPS_DIR    = r"C:\Projects\epic-clarity\python\maps"


# ----------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------
def load_zc_lookup(engine, table, code_col, name_col="NAME"):
    """Read a ZC_ table back as {name-lowercased: code}."""
    df = pd.read_sql(f"SELECT {code_col}, {name_col} FROM {table}", engine)
    return {str(n).strip().lower(): int(c)
            for c, n in zip(df[code_col], df[name_col])}


def save_map(name, mapping):
    """Persist an ID-mapping dict to python/maps/<name>.json"""
    os.makedirs(MAPS_DIR, exist_ok=True)
    path = os.path.join(MAPS_DIR, f"{name}.json")
    with open(path, "w") as f:
        json.dump(mapping, f, indent=2)
    print(f"  saved map: {path}  ({len(mapping)} entries)")


def load_map(name):
    """Load a previously-saved ID map from python/maps/<name>.json"""
    path = os.path.join(MAPS_DIR, f"{name}.json")
    with open(path) as f:
        return json.load(f)


def fit(value, max_len):
    """Trim text to max_len; handles messy source data."""
    if value is None:
        return None
    s = str(value).strip()
    return s[:max_len] if len(s) > max_len else s


def clean_date(value):
    """Return a date string or None. Synthea dates are ISO."""
    if value is None or str(value).strip() == "" or str(value) == "nan":
        return None
    return str(value).strip()[:10]


# ----------------------------------------------------------------
# Part A - PATIENT
# ----------------------------------------------------------------
def load_patients(engine):
    """patients.csv -> PATIENT.  Builds pat_id_map (UUID -> PAT_ID int)."""
    print("\n[Part A] Loading PATIENT from patients.csv")

    df = pd.read_csv(os.path.join(SYNTHEA_DIR, "patients.csv"))
    print(f"  read {len(df)} patients")

    race_map    = load_zc_lookup(engine, "ZC_RACE", "RACE_C")
    eth_map     = load_zc_lookup(engine, "ZC_ETHNICITY", "ETHNICITY_C")
    sex_map     = load_zc_lookup(engine, "ZC_SEX", "SEX_C", "ABBR")
    marital_map = load_zc_lookup(engine, "ZC_MARITAL_STATUS", "MARITAL_STATUS_C")
    state_map   = load_zc_lookup(engine, "ZC_STATE", "STATE_C", "NAME")

    race_text = {
        "white": "white", "black": "black or african american",
        "asian": "asian",
        "hawaiian": "native hawaiian or other pacific islander",
        "native": "american indian or alaska native",
        "other": "other race",
    }
    eth_text = {
        "hispanic": "hispanic or latino",
        "nonhispanic": "not hispanic or latino",
    }
    marital_text = {"m": "married", "s": "single"}

    rows = []
    pat_id_map = {}

    for i, row in df.iterrows():
        pat_id = i + 1
        pat_id_map[row["Id"]] = pat_id

        race_c = race_map.get(race_text.get(
            str(row.get("RACE", "")).strip().lower()))
        eth_c = eth_map.get(eth_text.get(
            str(row.get("ETHNICITY", "")).strip().lower()))
        sex_c = sex_map.get(str(row.get("GENDER", "")).strip().lower())
        marital_c = marital_map.get(marital_text.get(
            str(row.get("MARITAL", "")).strip().lower()))
        state_c = state_map.get(str(row.get("STATE", "")).strip().lower())

        death = clean_date(row.get("DEATHDATE"))

        rows.append({
            "PAT_ID":           pat_id,
            "PAT_MRN_ID":       f"MRN{pat_id:07d}",
            "PAT_FIRST_NAME":   fit("".join(c for c in str(row.get("FIRST", ""))
                                            if not c.isdigit()), 100),
            "PAT_LAST_NAME":    fit("".join(c for c in str(row.get("LAST", ""))
                                            if not c.isdigit()), 100),
            "PAT_MIDDLE_NAME":  None,
            "BIRTH_DATE":       clean_date(row.get("BIRTHDATE")),
            "DEATH_DATE":       death,
            "DECEASED_YN":      "Y" if death else "N",
            "SEX_C":            sex_c,
            "MARITAL_STATUS_C": marital_c,
            "RACE_C":           race_c,
            "ETHNICITY_C":      eth_c,
            "PAT_STATUS_C":     2 if death else 1,
            "ADD_LINE_1":       fit(row.get("ADDRESS"), 200),
            "CITY":             fit(row.get("CITY"), 100),
            "STATE_C":          state_c,
            "ZIP":              fit(row.get("ZIP"), 10),
            "COUNTY":           fit(row.get("COUNTY"), 100),
            "SSN":              fit(row.get("SSN"), 11),
            "ACTIVE_YN":        "Y",
        })

    pd.DataFrame(rows).to_sql("PATIENT", engine,
                              if_exists="append", index=False)
    print(f"  inserted {len(rows)} patients")

    save_map("pat_id_map", pat_id_map)
    return pat_id_map


# ----------------------------------------------------------------
# Part B - PAT_ENC + PAT_ENC_HSP
# ----------------------------------------------------------------
def load_encounters(engine):
    """encounters.csv -> PAT_ENC (all) + PAT_ENC_HSP (hospital types)."""
    print("\n[Part B] Loading PAT_ENC + PAT_ENC_HSP from encounters.csv")

    df = pd.read_csv(os.path.join(SYNTHEA_DIR, "encounters.csv"))
    print(f"  read {len(df)} encounters")

    pat_map  = load_map("pat_id_map")
    org_map  = load_map("org_id_map")
    prov_map = load_map("prov_id_map")

    enc_type = {
        "ambulatory": 1, "emergency": 2, "inpatient": 3,
        "outpatient": 4, "urgentcare": 5, "wellness": 6,
    }
    HOSPITAL_CLASSES = {"inpatient", "emergency"}

    enc_rows, hsp_rows = [], []
    csn_id_map = {}

    for i, row in df.iterrows():
        csn_id = 100000000 + i
        csn_id_map[row["Id"]] = csn_id

        ec = str(row.get("ENCOUNTERCLASS", "")).strip().lower()

        pat_id  = pat_map.get(row["PATIENT"])
        dept_id = org_map.get(row["ORGANIZATION"])
        prov_id = prov_map.get(row["PROVIDER"])

        start = clean_date(row.get("START"))

        enc_rows.append({
            "PAT_ENC_CSN_ID":  csn_id,
            "PAT_ID":          pat_id,
            "CONTACT_DATE":    start,
            "ENC_TYPE_C":      enc_type.get(ec),
            "DEPARTMENT_ID":   dept_id,
            "LOCATION_ID":     dept_id,
            "VISIT_PROV_ID":   prov_id,
            "ENC_CLOSED_YN":   "Y",
            "CHIEF_COMPLAINT": fit(row.get("REASONDESCRIPTION"), 500),
        })

        if ec in HOSPITAL_CLASSES:
            hsp_rows.append({
                "PAT_ENC_CSN_ID":       csn_id,
                "PAT_ID":               pat_id,
                "HOSP_ADMSN_TIME":      clean_date(row.get("START")),
                "HOSP_DISCH_TIME":      clean_date(row.get("STOP")),
                "ADT_PAT_CLASS_C":      1 if ec == "inpatient" else 4,
                "READMIT_FLAG_YN":      "N",
                "DEATH_DURING_STAY_YN": "N",
            })

    print(f"  prepared {len(enc_rows)} PAT_ENC rows, "
          f"{len(hsp_rows)} PAT_ENC_HSP rows")

    pd.DataFrame(enc_rows).to_sql("PAT_ENC", engine, if_exists="append",
                                  index=False, chunksize=1000)
    print(f"  inserted {len(enc_rows)} PAT_ENC rows")

    pd.DataFrame(hsp_rows).to_sql("PAT_ENC_HSP", engine, if_exists="append",
                                  index=False, chunksize=1000)
    print(f"  inserted {len(hsp_rows)} PAT_ENC_HSP rows")

    save_map("csn_id_map", csn_id_map)
    return csn_id_map


# ----------------------------------------------------------------
# Main
# ----------------------------------------------------------------
def main():
    print("=" * 60)
    print("ETL Stage 2.3 - Core Clinical Layer")
    print("=" * 60)

    engine = create_engine(CONNECTION_STRING)

    try:
        load_patients(engine)
        print("\nPart A complete.")
        load_encounters(engine)
        print("\nPart B complete. Stage 2.3 done.")
    except Exception as e:
        print("\nFAILED:", e)
        print("Note: duplicate-key error means a table already has data.")


if __name__ == "__main__":
    main()