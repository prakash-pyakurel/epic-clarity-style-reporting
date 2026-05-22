"""
explore_claims.py
-----------------
Read-only investigation of Synthea's two claims files.
Prints column inventory + a few sample values, so the Stage 2.5
financial loader is built against real structure.

NO database. NO writes. Reads CSVs and prints only.
"""

import pandas as pd
import os

SYNTHEA_DIR = r"C:\Projects\epic-clarity\data\raw\synthea"

FILES = ["claims.csv", "claims_transactions.csv"]


def explore():
    for filename in FILES:
        path = os.path.join(SYNTHEA_DIR, filename)
        print("\n" + "=" * 60)
        print(f"FILE: {filename}")
        print("=" * 60)

        if not os.path.exists(path):
            print(f"  !! not found at {path}")
            continue

        df = pd.read_csv(path, low_memory=False)
        print(f"  Rows: {len(df)}   Columns: {len(df.columns)}")

        print("\n  Column list:")
        for c in df.columns:
            print(f"    - {c}")

        # Show the first 2 rows transposed, so every column value is readable
        print("\n  Sample (first 2 rows):")
        sample = df.head(2).to_dict(orient="records")
        for idx, rec in enumerate(sample):
            print(f"\n  --- row {idx + 1} ---")
            for k, v in rec.items():
                print(f"    {k}: {v}")


if __name__ == "__main__":
    explore()