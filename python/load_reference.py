"""
load_reference.py
-----------------
ETL Stage 2.2 - Reference Layer

Loads the four CLARITY_ reference tables from Synthea source CSVs:
  organizations.csv -> CLARITY_LOC + CLARITY_DEP
  providers.csv     -> CLARITY_SER
  payers.csv        -> CLARITY_PAYOR

Builds and persists ID-mapping dictionaries (Synthea UUID -> our ID)
to python/maps/ as JSON, for use by later ETL stages.

Project: Epic Clarity-Style Clinical Reporting & Analytics Platform
Phase:   2 - ETL  |  Stage: 2.2 - Reference layer
"""

import os
import json
import pandas as pd
from sqlalchemy import create_engine, text

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
    """Read a ZC_ table back from the DB as a {NAME-lowercased: code} dict.
    Used to translate Synthea text values into our integer _C codes."""
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


def fit(value, max_len):
    """Trim a text value to max_len so it can't overflow its column.
    Handles messy Synthea source data (e.g. doubled phone numbers)."""
    if value is None:
        return None
    s = str(value).strip()
    return s[:max_len] if len(s) > max_len else s


# ----------------------------------------------------------------
# Stage 2.2 loaders
# ----------------------------------------------------------------
def load_locations_and_departments(engine):
    """organizations.csv -> CLARITY_LOC and CLARITY_DEP.
    Each Synthea organization becomes one location AND one department."""
    print("\n[1/3] Loading CLARITY_LOC + CLARITY_DEP from organizations.csv")

    df = pd.read_csv(os.path.join(SYNTHEA_DIR, "organizations.csv"))
    print(f"  read {len(df)} organizations")

    state_map = load_zc_lookup(engine, "ZC_STATE", "STATE_C", "ABBR")

    loc_rows, dep_rows = [], []
    org_id_map = {}   # Synthea org UUID -> our integer ID

    for i, row in df.iterrows():
        new_id = i + 1                       # integer ID, sequential from 1
        org_id_map[row["Id"]] = new_id

        state_c = state_map.get(str(row.get("STATE", "")).strip().lower())

        loc_rows.append({
            "LOCATION_ID":    new_id,
            "LOC_NAME":       fit(row["NAME"], 100),
            "LOC_ABBR":       None,
            "LOC_TYPE_C":     1,             # 1 = Hospital (ZC_LOC_TYPE)
            "ADDRESS_LINE_1": fit(row.get("ADDRESS"), 200),
            "CITY":           fit(row.get("CITY"), 100),
            "STATE_C":        state_c,
            "ZIP":            fit(row.get("ZIP"), 10),
            "PHONE":          fit(row.get("PHONE"), 20),
            "ACTIVE_YN":      "Y",
        })
        dep_rows.append({
            "DEPARTMENT_ID":   new_id,
            "DEPARTMENT_NAME": fit(row["NAME"], 100),
            "SPECIALTY_C":     None,         # orgs have no specialty in Synthea
            "LOCATION_ID":     new_id,       # department sits at its location
            "DEPT_TYPE_C":     1,            # 1 = Inpatient Unit (ZC_DEPT_TYPE)
            "ACTIVE_YN":       "Y",
        })

    pd.DataFrame(loc_rows).to_sql("CLARITY_LOC", engine,
                                  if_exists="append", index=False)
    pd.DataFrame(dep_rows).to_sql("CLARITY_DEP", engine,
                                  if_exists="append", index=False)
    print(f"  inserted {len(loc_rows)} locations, {len(dep_rows)} departments")

    save_map("org_id_map", org_id_map)
    return org_id_map


def load_providers(engine):
    """providers.csv -> CLARITY_SER. PROV_ID is varchar -> string IDs."""
    print("\n[2/3] Loading CLARITY_SER from providers.csv")

    df = pd.read_csv(os.path.join(SYNTHEA_DIR, "providers.csv"))
    print(f"  read {len(df)} providers")

    spec_map = load_zc_lookup(engine, "ZC_DEP_SPECIALTY", "SPECIALTY_C")

    ser_rows = []
    prov_id_map = {}   # Synthea provider UUID -> our string PROV_ID

    for i, row in df.iterrows():
        prov_id = f"P{i + 1:06d}"            # e.g. P000001
        prov_id_map[row["Id"]] = prov_id

        specialty_c = spec_map.get(str(row.get("SPECIALITY", "")).strip().lower())

        # split "First Last" name; Synthea NAME has digits we strip
        full = str(row.get("NAME", "")).strip()
        clean = "".join(ch for ch in full if not ch.isdigit())
        parts = clean.split()
        first = parts[0] if parts else None
        last  = parts[-1] if len(parts) > 1 else None

        ser_rows.append({
            "PROV_ID":          prov_id,
            "PROV_NAME":        fit(clean, 200),
            "PROV_FIRST_NAME":  fit(first, 100),
            "PROV_LAST_NAME":   fit(last, 100),
            "PROV_TYPE":        "Physician",
            "SPECIALTY_C":      specialty_c,
            "ACTIVE_YN":        "Y",
            "EMPLOYEE_YN":      "Y",
            "EXTERNAL_USER_YN": "N",
        })

    pd.DataFrame(ser_rows).to_sql("CLARITY_SER", engine,
                                  if_exists="append", index=False)
    print(f"  inserted {len(ser_rows)} providers")

    save_map("prov_id_map", prov_id_map)
    return prov_id_map


def load_payors(engine):
    """payers.csv -> CLARITY_PAYOR."""
    print("\n[3/3] Loading CLARITY_PAYOR from payers.csv")

    df = pd.read_csv(os.path.join(SYNTHEA_DIR, "payers.csv"))
    print(f"  read {len(df)} payers")

    # Map payer name -> payor type code (ZC_PAYOR_TYPE)
    # 1 Commercial, 2 Medicare, 3 Medicaid, 4 Self-Pay, 5 Other Govt
    def payor_type(name):
        n = str(name).lower()
        if "medicare" in n:            return 2
        if "medicaid" in n:            return 3
        if "dual" in n:                return 5
        if "no_insurance" in n:        return 4
        return 1                       # commercial default

    payor_rows = []
    payor_id_map = {}

    for i, row in df.iterrows():
        new_id = i + 1
        payor_id_map[row["Id"]] = new_id

        payor_rows.append({
            "PAYOR_ID":     new_id,
            "PAYOR_NAME":   fit(row["NAME"], 200),
            "PAYOR_ABBR":   None,
            "PAYOR_TYPE_C": payor_type(row["NAME"]),
            "CITY":         fit(row.get("CITY"), 100),
            "ZIP":          fit(row.get("ZIP"), 10),
            "PHONE":        fit(row.get("PHONE"), 20),
            "ACTIVE_YN":    "Y",
        })

    pd.DataFrame(payor_rows).to_sql("CLARITY_PAYOR", engine,
                                    if_exists="append", index=False)
    print(f"  inserted {len(payor_rows)} payors")

    save_map("payor_id_map", payor_id_map)
    return payor_id_map


# ----------------------------------------------------------------
# Main
# ----------------------------------------------------------------
def main():
    print("=" * 60)
    print("ETL Stage 2.2 - Reference Layer")
    print("=" * 60)

    engine = create_engine(CONNECTION_STRING)

    try:
        load_locations_and_departments(engine)
        load_providers(engine)
        load_payors(engine)
        print("\nStage 2.2 complete.")
    except Exception as e:
        print("\nFAILED:", e)
        print("Note: if this is a duplicate-key error, the CLARITY_ "
              "tables already have data - they must be empty to re-run.")


if __name__ == "__main__":
    main()