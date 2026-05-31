import sqlite3
from pathlib import Path

import pandas as pd


# Build paths relative to the project root.
root = Path(__file__).resolve().parent

# Local SQLite database created by load_to_sqlite.py.
db_path = root / "hospital_quality.db"

# Folder where exported reporting CSV files will be saved.
output_folder = root / "data" / "output"


exports = {
    "state_summary": "SELECT * FROM state_summary",
    "state_rating_rankings": "SELECT * FROM state_rating_rankings",
    "state_quality_domain_summary": "SELECT * FROM state_quality_domain_summary",

    "ownership_summary": "SELECT * FROM ownership_summary",
    "ownership_rating_rankings": "SELECT * FROM ownership_rating_rankings",
    "ownership_quality_domain_summary": "SELECT * FROM ownership_quality_domain_summary",

    "hospital_type_summary": "SELECT * FROM hospital_type_summary",
    "hospital_type_rating_rankings": "SELECT * FROM hospital_type_rating_rankings",
    "hospital_type_quality_domain_summary": "SELECT * FROM hospital_type_quality_domain_summary",

    "quality_domain_summary": "SELECT * FROM quality_domain_summary",
    "quality_domain_missingness": "SELECT * FROM quality_domain_missingness",
    "quality_domain_below_average": "SELECT * FROM quality_domain_below_average",
}


def main():
    if not db_path.exists():
        raise FileNotFoundError(f"Could not find database: {db_path}")

    output_folder.mkdir(parents=True, exist_ok=True)

    with sqlite3.connect(db_path) as connection:
        for file_name, query in exports.items():
            export_path = output_folder / f"{file_name}.csv"

            result = pd.read_sql_query(query, connection)
            result.to_csv(export_path, index=False)

            print(f"Exported {len(result)} rows to {export_path}")


if __name__ == "__main__":
    main()