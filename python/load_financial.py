"""
load_financial.py
-----------------
ETL Stage 2.5 - Financial Layer

claims.csv              -> HSP_ACCOUNT (1:1 per claim) + CLAIM_INFO
claims_transactions.csv -> CHARGE_DETAIL  (TYPE=CHARGE)
                         + PAYMENT_DETAIL (TYPE=PAYMENT)
                         + ARPB_TRANSACTIONS (all rows)

Uses pat_id_map from earlier stages. Builds claim_id_map.

Project: Epic Clarity-Style Clinical Reporting & Analytics Platform
Phase:   2 - ETL  |  Stage: 2.5 - Financial layer
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


def save_map(name, mapping):
    os.makedirs(MAPS_DIR, exist_ok=True)
    path = os.path.join(MAPS_DIR, f"{name}.json")
    with open(path, "w") as f:
        json.dump(mapping, f, indent=2)
    print(f"  saved map: {path}  ({len(mapping)} entries)")


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
    """Return float or None for possibly-blank numeric columns."""
    try:
        if value is None or str(value).strip() == "" or str(value) == "nan":
            return None
        return float(value)
    except (ValueError, TypeError):
        return None


# ----------------------------------------------------------------
# HSP_ACCOUNT + CLAIM_INFO  <- claims.csv
# ----------------------------------------------------------------
def load_accounts_and_claims(engine, pat_map):
    print("\n[1/3] Loading HSP_ACCOUNT + CLAIM_INFO from claims.csv")
    df = pd.read_csv(os.path.join(SYNTHEA_DIR, "claims.csv"), low_memory=False)
    print(f"  read {len(df)} claims")

    acct_rows, claim_rows = [], []
    claim_id_map = {}     # Synthea claim UUID -> our integer CLAIM_ID
    acct_id_map  = {}     # Synthea claim UUID -> our integer HSP_ACCOUNT_ID

    for i, row in df.iterrows():
        pat_id = pat_map.get(row["PATIENTID"])
        if pat_id is None:
            continue                       # skip orphan claims

        new_id = i + 1                     # shared id: 1:1 account-per-claim
        claim_id_map[row["Id"]] = new_id
        acct_id_map[row["Id"]]  = new_id

        service = clean_date(row.get("SERVICEDATE"))
        status  = str(row.get("STATUSP", "")).strip().upper()
        # STATUSP CLOSED -> claim status 7 Closed; else 1 Submitted
        claim_status_c = 7 if status == "CLOSED" else 1

        acct_rows.append({
            "HSP_ACCOUNT_ID":  new_id,
            "PAT_ID":          pat_id,
            "ACCT_STATUS_C":   2 if status == "CLOSED" else 1,  # 2 Closed 1 Open
            "ADMIT_DATE":      service,
            "DISCH_DATE":      service,
        })
        claim_rows.append({
            "CLAIM_ID":          new_id,
            "HSP_ACCOUNT_ID":    new_id,
            "PAT_ID":            pat_id,
            "CLAIM_STATUS_C":    claim_status_c,
            "CLAIM_TYPE_C":      2,                      # 2 Professional
            "SERVICE_FROM_DATE": service,
            "SERVICE_TO_DATE":   service,
        })

    pd.DataFrame(acct_rows).to_sql("HSP_ACCOUNT", engine, if_exists="append",
                                   index=False, chunksize=1000)
    print(f"  inserted {len(acct_rows)} HSP_ACCOUNT rows")

    pd.DataFrame(claim_rows).to_sql("CLAIM_INFO", engine, if_exists="append",
                                    index=False, chunksize=1000)
    print(f"  inserted {len(claim_rows)} CLAIM_INFO rows")

    save_map("claim_id_map", claim_id_map)
    save_map("acct_id_map", acct_id_map)
    return claim_id_map, acct_id_map


# ----------------------------------------------------------------
# CHARGE_DETAIL + PAYMENT_DETAIL + ARPB_TRANSACTIONS
#   <- claims_transactions.csv
# ----------------------------------------------------------------
def load_transactions(engine, pat_map, claim_map, acct_map):
    print("\n[2/3] Reading claims_transactions.csv")
    df = pd.read_csv(os.path.join(SYNTHEA_DIR, "claims_transactions.csv"),
                     low_memory=False)
    print(f"  read {len(df)} transactions")

    charge_rows, payment_rows, arpb_rows = [], [], []

    for i, row in df.iterrows():
        pat_id   = pat_map.get(row["PATIENTID"])
        acct_id  = acct_map.get(row.get("CLAIMID"))
        if pat_id is None or acct_id is None:
            continue                       # skip orphans

        ttype   = str(row.get("TYPE", "")).strip().upper()
        amount  = to_num(row.get("AMOUNT"))
        from_dt = clean_date(row.get("FROMDATE"))

        # ARPB_TRANSACTIONS - every transaction row
        # tx type: 1 Charge, 2 Payment, 3 Adjustment, 5 Transfer
        tx_type_c = {"CHARGE": 1, "PAYMENT": 2,
                     "ADJUSTMENT": 3, "TRANSFEROUT": 5,
                     "TRANSFERIN": 5}.get(ttype, 1)
        arpb_rows.append({
            "TX_ID":          i + 1,
            "PAT_ID":         pat_id,
            "HSP_ACCOUNT_ID": acct_id,
            "TX_TYPE_C":      tx_type_c,
            "TX_AMOUNT":      amount if amount is not None
                              else to_num(row.get("PAYMENTS")),
            "PROCEDURE_DESC": fit(row.get("NOTES"), 500),
            "SERVICE_FROM_DATE": from_dt,
            "POST_DATE":      from_dt,
        })

        if ttype == "CHARGE":
            charge_rows.append({
                "CHARGE_ID":          i + 1,
                "HSP_ACCOUNT_ID":     acct_id,
                "PAT_ID":             pat_id,
                "CHARGE_DESCRIPTION": fit(row.get("NOTES"), 500),
                "SERVICE_DATE":       from_dt,
                "POST_DATE":          from_dt,
                "QUANTITY":           to_num(row.get("UNITS")),
                "UNIT_PRICE":         to_num(row.get("UNITAMOUNT")),
                "CHARGE_AMOUNT":      amount,
                "CHARGE_STATUS_C":    1,            # 1 Posted
            })
        elif ttype == "PAYMENT":
            payment_rows.append({
                "PAYMENT_ID":       i + 1,
                "HSP_ACCOUNT_ID":   acct_id,
                "PAT_ID":           pat_id,
                "PAYMENT_AMOUNT":   to_num(row.get("PAYMENTS")) or 0,
                "PAYMENT_DATE":     from_dt,
                "POST_DATE":        from_dt,
                "PAYMENT_TYPE_C":   1,              # 1 Insurance Payment
                "PAYMENT_SOURCE_C": 1,              # 1 Insurance
            })

    print(f"  prepared: {len(arpb_rows)} ARPB, "
          f"{len(charge_rows)} charges, {len(payment_rows)} payments")

    print("\n[3/3] Inserting financial transaction tables")

    pd.DataFrame(charge_rows).to_sql("CHARGE_DETAIL", engine,
                                     if_exists="append", index=False,
                                     chunksize=1000)
    print(f"  inserted {len(charge_rows)} CHARGE_DETAIL rows")

    pd.DataFrame(payment_rows).to_sql("PAYMENT_DETAIL", engine,
                                      if_exists="append", index=False,
                                      chunksize=1000)
    print(f"  inserted {len(payment_rows)} PAYMENT_DETAIL rows")

    pd.DataFrame(arpb_rows).to_sql("ARPB_TRANSACTIONS", engine,
                                   if_exists="append", index=False,
                                   chunksize=1000)
    print(f"  inserted {len(arpb_rows)} ARPB_TRANSACTIONS rows")


# ----------------------------------------------------------------
# Main
# ----------------------------------------------------------------
def main():
    print("=" * 60)
    print("ETL Stage 2.5 - Financial Layer")
    print("=" * 60)

    engine = create_engine(CONNECTION_STRING)

    pat_map = load_map("pat_id_map")
    print(f"loaded map: {len(pat_map)} patients")

    try:
        claim_map, acct_map = load_accounts_and_claims(engine, pat_map)
        load_transactions(engine, pat_map, claim_map, acct_map)
        print("\nStage 2.5 complete.")
    except Exception as e:
        print("\nFAILED:", e)
        print("Note: duplicate-key error means a table already has data.")


if __name__ == "__main__":
    main()