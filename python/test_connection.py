"""
test_connection.py
------------------
Purpose: Verify that Python can connect to the EpicClaritySim
SQL Server database through SQLAlchemy + pyodbc.

This script performs NO ETL. It is a one-time bridge test:
connect, run SELECT 1, confirm the result, close cleanly.

Project: Epic Clarity-Style Clinical Reporting & Analytics Platform
Phase:   2 - ETL  |  Stage: 2.0d - Environment connection test
"""

from sqlalchemy import create_engine, text

# --- Connection configuration -------------------------------------------
SERVER   = "PRAKASH"
DATABASE = "EpicClaritySim"
DRIVER   = "ODBC Driver 17 for SQL Server"

# Build the SQLAlchemy connection string (Windows Authentication)
CONNECTION_STRING = (
    f"mssql+pyodbc://@{SERVER}/{DATABASE}"
    f"?driver={DRIVER.replace(' ', '+')}"
    f"&trusted_connection=yes"
)

# --- Connection test ----------------------------------------------------
def main():
    print("Attempting to connect to:", f"{SERVER} / {DATABASE}")

    try:
        engine = create_engine(CONNECTION_STRING)

        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            value = result.scalar()

            if value == 1:
                print("SUCCESS: Connection works. SELECT 1 returned 1.")
            else:
                print(f"UNEXPECTED: Connected, but SELECT 1 returned {value}.")

    except Exception as e:
        print("FAILED: Could not connect.")
        print("Error detail:", e)


if __name__ == "__main__":
    main()