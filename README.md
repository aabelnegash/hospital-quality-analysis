# Hospital Quality Analysis

## Project overview

This project analyzes cleaned CMS hospital data using SQL, Excel, and Power BI.

The cleaned dataset comes from a separate Python/pandas cleaning project. This project starts with the cleaned CSV, loads it into SQLite, runs SQL analysis, and later uses the results for reporting and dashboarding.

## Data source

The dataset used in this project is the cleaned version of the CMS Hospital General Information dataset.

The cleaning step was completed in a separate project:

- Standardized column names
- Cleaned key fields such as state, ZIP code, phone number, and provider ID
- Removed unnecessary footnote columns
- Validated the cleaned output

### Missing values

The original cleaning pipeline converted placeholder labels such as `"Not Available"`, `"Not Applicable"`, `"N/A"`, `"NA"`, and blank cells into true missing values.

When this cleaned CSV is loaded into SQLite through pandas, those missing values are preserved as SQL `NULL` values. This keeps SQL filtering and aggregation cleaner. For example, missing hospital ratings are queried with `IS NULL`, not by searching for text labels like `"N/A"`.

## Project workflow

```text
Cleaned hospital CSV
→ SQLite database
→ SQL analysis
→ Excel reporting
→ Power BI dashboard

## Folder structure

## How to run

## SQL analysis

## Excel reporting

## Power BI dashboard