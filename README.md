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

## SQL analysis progress

The SQL analysis currently includes:

- Database preview and schema checks
- Data quality checks for key fields
- Quality domain analysis using national comparison fields
- State-level hospital summaries and rating rankings
- Ownership-level hospital summaries and rating rankings
- Hospital type summaries and rating rankings

Each major analysis level includes two types of outputs:

- **Summary tables** describe the group overall, including total hospitals, rated hospitals, emergency service coverage, missing ratings, and average rating.
- **Sample-adjusted rating ranking tables** compare average ratings while reducing the influence of groups with very small numbers of rated hospitals.

## Analysis notes

Missing ratings are treated as missing values, not zeroes. Rating averages are calculated only from hospitals with available overall ratings.

Because some states, ownership types, and hospital types have far fewer rated hospitals than others, raw average ratings can be misleading. To address this, I utilized a sample-adjusted rating score across the state, ownership, and hospital type analysis files:

`sample_adjusted_rating_score = avg_rating * rated_hospitals / (rated_hospitals + 20)`

This score is not an official CMS metric. It is used only as an internal ranking aid for this analysis.

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