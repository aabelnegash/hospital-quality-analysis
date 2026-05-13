import sqlite3
from pathlib import Path

import pandas as pd 

root = Path(__file__).resolve().parent

csv_path = root / "data" / "input" / "hospital_clean.csv"
db_path = root / "hospital_quality.db"

table_name = "hospitals"



def main(): 
    if not csv_path.exists():
        raise FileNotFoundError(f"Could not find input CSV: {csv_path}")
    
    hospital_data = pd.read_csv(
        csv_path,
        dtype="string",
        keep_default_na=True
    )

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