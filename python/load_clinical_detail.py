"""
load_clinical_detail.py
-----------------------
ETL Stage 2.4 - Clinical Detail Layer

conditions.csv   -> PROBLEM_LIST
medications.csv  -> ORDER_MED
procedures.csv   -> ORDER_PROC
observations.csv -> LAB_RESULTS

Uses pat_id_map and csn_id_map from earlier stages.

Project: Epic Clarity-Style Clinical Reporting & Analytics Platform
Phase:   2 - ETL  |  Stage: 2.4 - Clinical detail
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
def load_map(name):
    path = os.path.join(MAPS_DIR, f"{name}.json")
    with open(path) as f:
        return json.load(f)


def fit(value, max_len):
    if value is None:
        return None
    s = str(value).strip()
    if s == "" or s == "nan":
        return None
    return s[:max_len] if len(s) > max_len else s


def clean_date(value):
    if value is None or str(value).strip() == "" or str(value) == "nan":
        return None
    return str(value).strip()[:10]


def to_num(value):
    """Return a float or None - for numeric columns that may be blank."""
    try:
        if value is None or str(value).strip() == "" or str(value) == "nan":
            return None
        return float(value)
    except (ValueError, TypeError):
        return None


# ----------------------------------------------------------------
# PROBLEM_LIST  <- conditions.csv
# ----------------------------------------------------------------
def load_problems(engine, pat_map, csn_map):
    print("\n[1/4] Loading PROBLEM_LIST from conditions.csv")
    df = pd.read_csv(os.path.join(SYNTHEA_DIR, "conditions.csv"))
    print(f"  read {len(df)} conditions")

    rows = []
    for i, row in df.iterrows():
        pat_id = pat_map.get(row["PATIENT"])
        if pat_id is None:
            continue                       # skip orphan rows
        resolved = clean_date(row.get("STOP"))
        rows.append({
            "PROBLEM_LIST_ID":     i + 1,
            "PAT_ID":              pat_id,
            "SNOMED_CODE":         fit(row.get("CODE"), 20),
            "PROBLEM_DESCRIPTION": fit(row.get("DESCRIPTION"), 500),
            "NOTED_DATE":          clean_date(row.get("START")),
            "RESOLVED_DATE":       resolved,
            "PROBLEM_STATUS_C":    2 if resolved else 1,   # 2 Resolved 1 Active
            "CHRONIC_YN":          "N",
            "PRINCIPAL_PR_YN":     "N",
            "DIAG_ENC_CSN_ID":     csn_map.get(row.get("ENCOUNTER")),
        })

    pd.DataFrame(rows).to_sql("PROBLEM_LIST", engine, if_exists="append",
                              index=False, chunksize=1000)
    print(f"  inserted {len(rows)} problem list rows")


# ----------------------------------------------------------------
# ORDER_MED  <- medications.csv
# ----------------------------------------------------------------
def load_medications(engine, pat_map, csn_map):
    print("\n[2/4] Loading ORDER_MED from medications.csv")
    df = pd.read_csv(os.path.join(SYNTHEA_DIR, "medications.csv"))
    print(f"  read {len(df)} medications")

    rows = []
    for i, row in df.iterrows():
        pat_id = pat_map.get(row["PATIENT"])
        if pat_id is None:
            continue
        stop = clean_date(row.get("STOP"))
        rows.append({
            "ORDER_MED_ID":    i + 1,
            "PAT_ID":          pat_id,
            "PAT_ENC_CSN_ID":  csn_map.get(row.get("ENCOUNTER")),
            "RXNORM_CODE":     fit(row.get("CODE"), 20),
            "MEDICATION_NAME": fit(row.get("DESCRIPTION"), 500),
            "ORDER_STATUS_C":  3 if stop else 1,   # 3 Discontinued 1 Active
            "ORDER_TYPE_C":    1,                  # 1 Medication
            "ORDERING_DATE":   clean_date(row.get("START")),
            "START_DATE":      clean_date(row.get("START")),
            "END_DATE":        stop,
        })

    pd.DataFrame(rows).to_sql("ORDER_MED", engine, if_exists="append",
                              index=False, chunksize=1000)
    print(f"  inserted {len(rows)} medication order rows")


# ----------------------------------------------------------------
# ORDER_PROC  <- procedures.csv
# ----------------------------------------------------------------
def load_procedures(engine, pat_map, csn_map):
    print("\n[3/4] Loading ORDER_PROC from procedures.csv")
    df = pd.read_csv(os.path.join(SYNTHEA_DIR, "procedures.csv"))
    print(f"  read {len(df)} procedures")

    rows = []
    for i, row in df.iterrows():
        pat_id = pat_map.get(row["PATIENT"])
        if pat_id is None:
            continue
        rows.append({
            "ORDER_PROC_ID":   i + 1,
            "PAT_ID":          pat_id,
            "PAT_ENC_CSN_ID":  csn_map.get(row.get("ENCOUNTER")),
            "SNOMED_CODE":     fit(row.get("CODE"), 20),
            "PROC_NAME":       fit(row.get("DESCRIPTION"), 500),
            "PROC_CATEGORY_C": 3,            # 3 Surgical (generic default)
            "IS_LAB_YN":       "N",
            "IS_IMAGING_YN":   "N",
            "ORDER_STATUS_C":  2,            # 2 Completed
            "RESULT_STATUS_C": 1,            # 1 Final
            "ORDER_TYPE_C":    4,            # 4 Procedure
            "ORDERING_DATE":   clean_date(row.get("START")),
            "RESULT_DATE":     clean_date(row.get("STOP")),
            "REASON_FOR_ORDER": fit(row.get("REASONDESCRIPTION"), 500),
        })

    pd.DataFrame(rows).to_sql("ORDER_PROC", engine, if_exists="append",
                              index=False, chunksize=1000)
    print(f"  inserted {len(rows)} procedure order rows")


# ----------------------------------------------------------------
# LAB_RESULTS  <- observations.csv  (largest file)
# ----------------------------------------------------------------
def load_lab_results(engine, pat_map, csn_map):
    print("\n[4/4] Loading LAB_RESULTS from observations.csv")
    df = pd.read_csv(os.path.join(SYNTHEA_DIR, "observations.csv"),
                     low_memory=False)
    print(f"  read {len(df)} observations")

    rows = []
    for i, row in df.iterrows():
        pat_id = pat_map.get(row["PATIENT"])
        if pat_id is None:
            continue
        num_val = to_num(row.get("VALUE"))
        rows.append({
            "RESULT_ID":       i + 1,
            "PAT_ID":          pat_id,
            "PAT_ENC_CSN_ID":  csn_map.get(row.get("ENCOUNTER")),
            "LOINC_CODE":      fit(row.get("CODE"), 20),
            "COMPONENT_NAME":  fit(row.get("DESCRIPTION"), 500),
            "ORD_VALUE":       fit(row.get("VALUE"), 500),
            "ORD_NUM_VALUE":   num_val,
            "REFERENCE_UNIT":  fit(row.get("UNITS"), 50),
            "RESULT_STATUS_C": 1,            # 1 Final
            "RESULT_DATE":     clean_date(row.get("DATE")),
        })

    print(f"  prepared {len(rows)} lab result rows - inserting...")
    pd.DataFrame(rows).to_sql("LAB_RESULTS", engine, if_exists="append",
                              index=False, chunksize=1000)
    print(f"  inserted {len(rows)} lab result rows")


# ----------------------------------------------------------------
# Main
# ----------------------------------------------------------------
def main():
    print("=" * 60)
    print("ETL Stage 2.4 - Clinical Detail Layer")
    print("=" * 60)

    engine = create_engine(CONNECTION_STRING)

    pat_map = load_map("pat_id_map")
    csn_map = load_map("csn_id_map")
    print(f"loaded maps: {len(pat_map)} patients, {len(csn_map)} encounters")

    try:
        load_problems(engine, pat_map, csn_map)
        load_medications(engine, pat_map, csn_map)
        load_procedures(engine, pat_map, csn_map)
        load_lab_results(engine, pat_map, csn_map)
        print("\nStage 2.4 complete.")
    except Exception as e:
        print("\nFAILED:", e)
        print("Note: duplicate-key error means a table already has data.")


if __name__ == "__main__":
    main()