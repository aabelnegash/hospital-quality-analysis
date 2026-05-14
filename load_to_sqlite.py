import sqlite3
from pathlib import Path

import pandas as pd 

# Build paths relative to project root instead of hardcoded local paths
root = Path(__file__).resolve().parent

# Full cleaned CSV from Project1. Ignored by Git
csv_path = root / "data" / "input" / "hospital_clean.csv"

# Local SQLite db created from CSV. Ignored by Git
db_path = root / "hospital_quality.db"

table_name = "hospitals"



def main(): 
    if not csv_path.exists():
        raise FileNotFoundError(f"Could not find input CSV: {csv_path}")
    
    # Load CSV into pandas df. Keep Fields as strings.
    hospital_data = pd.read_csv(
        csv_path,
        dtype="string",
        keep_default_na=True
    )

    # Create/open the db and replace the hospitals table with the latest clean data.
    with sqlite3.connect(db_path) as connection:
        hospital_data.to_sql(
            table_name,
            connection,
            if_exists="replace",
            index=False
        )

    print(f"Loaded {len(hospital_data)} rows into table: {table_name}")
    print(f"Database created: {db_path}")


if __name__ == "__main__":
    main()