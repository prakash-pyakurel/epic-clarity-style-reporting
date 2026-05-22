"""
explore_synthea.py
------------------
Purpose: Read-only investigation of Synthea source CSVs.
Prints column inventories and distinct values that feed the
source-driven ZC_ lookup tables (Stage 2.1, Bucket A).

NO database connection. NO writes. Reads CSVs and prints only.

Project: Epic Clarity-Style Clinical Reporting & Analytics Platform
Phase:   2 - ETL  |  Stage: 2.1 - ZC_ population (investigation)
"""

import pandas as pd
import os

SYNTHEA_DIR = r"C:\Projects\epic-clarity\data\raw\synthea"

# Distinct-value targets: (csv filename, [columns to inspect])
TARGETS = [
    ("patients.csv",      ["RACE", "ETHNICITY", "GENDER", "MARITAL"]),
    ("encounters.csv",    ["ENCOUNTERCLASS"]),
    ("providers.csv",     ["SPECIALITY", "GENDER"]),
    ("payers.csv",        ["NAME"]),
]

# Files to dump full column lists for (so nothing relevant is missed)
COLUMN_DUMP_FILES = [
    "patients.csv", "encounters.csv", "organizations.csv",
    "providers.csv", "payers.csv",
]


def section(title):
    print("\n" + "=" * 60)
    print(title)
    print("=" * 60)


def explore_distinct():
    for filename, columns in TARGETS:
        path = os.path.join(SYNTHEA_DIR, filename)
        section(f"DISTINCT VALUES: {filename}")

        if not os.path.exists(path):
            print(f"  !! File not found at {path}")
            continue

        df = pd.read_csv(path, low_memory=False)
        print(f"  Rows: {len(df)}   Total columns: {len(df.columns)}")

        for col in columns:
            print(f"\n  --- Column: {col} ---")
            if col not in df.columns:
                print(f"      (column '{col}' not present)")
                continue

            distinct = df[col].dropna().unique()
            print(f"      distinct value count: {len(distinct)}")
            # Print ALL distinct values this time (no 30-cap)
            for val in sorted(distinct.astype(str)):
                print(f"        - {val}")


def dump_columns():
    section("COLUMN INVENTORY (all relevant files)")
    for filename in COLUMN_DUMP_FILES:
        path = os.path.join(SYNTHEA_DIR, filename)
        print(f"\n  {filename}")
        if not os.path.exists(path):
            print(f"    !! File not found")
            continue
        df = pd.read_csv(path, low_memory=False, nrows=1)
        for c in df.columns:
            print(f"    - {c}")


if __name__ == "__main__":
    explore_distinct()
    dump_columns()