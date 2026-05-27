# Hospital Quality Analysis

## Project overview

This project analyzes cleaned CMS hospital data using SQL, Excel, and Power BI.

The cleaned dataset comes from a separate Python/pandas cleaning project. This project starts with the cleaned CSV, loads it into SQLite, runs SQL analysis, and will later use the SQL results for reporting and dashboarding.

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
```

## SQL Analysis

The SQL analysis currently includes:

- Database preview and schema checks
- Data quality checks for key fields
- Quality domain analysis using national comparison fields
- State-level hospital summaries and rating rankings
- Ownership-level hospital summaries and rating rankings
- Hospital type summaries and rating rankings

Each major analysis level includes three types of outputs:

- **Summary tables** describe each group overall, including total hospitals, rated hospitals, emergency service coverage, missing ratings, and average rating.
- **Sample-adjusted rating ranking tables** compare average ratings while reducing the influence of groups with very small numbers of rated hospitals.
- **Quality domain comparison tables** connect national comparison fields back to each analysis level, showing how below-average or missing quality-domain results vary by state, ownership type, and hospital type.

## SQL analysis methodology

The SQL workflow starts by confirming that the cleaned CSV loaded correctly into SQLite. After that, quality checks are used to validate important fields such as provider IDs, ZIP codes, phone numbers, state codes, and hospital ratings.

The main analysis is grouped across three levels:

- State
- Hospital ownership type
- Hospital type

The project also analyzes CMS national comparison fields across quality domains. These include mortality, safety of care, readmission, patient experience, effectiveness of care, timeliness of care, and efficient use of medical imaging.

These quality domain fields are categorical, not numeric. Instead of averaging them, the SQL analysis counts how many hospitals are above, same as, below, or missing compared to the national average.

The quality domain analysis reshapes these columns from wide format into long format using `UNION ALL`. This makes it easier to compare national comparison results across domains and connect those results back to state, ownership, and hospital type analysis.

## Sample-adjusted rating score

Raw average ratings can be misleading when a group has very few rated hospitals. For example, a state, ownership type, or hospital type with only a small number of rated hospitals can appear near the top of a ranking even though the sample size is weak.

To reduce that issue, I utilized a sample-adjusted rating score across the state, ownership, and hospital type analysis files:

`sample_adjusted_rating_score = avg_rating * rated_hospitals / (rated_hospitals + 20)`

This score is not an official CMS metric. It is used only as an internal ranking aid for this analysis.

The main summary tables still include the raw average rating, but rating ranking tables use the sample-adjusted score to provide better context.

## Important analysis notes

Missing ratings are treated as missing values, not zeroes. Rating averages are calculated only from hospitals with available overall ratings.

Some hospital groups have limited rating coverage. For example, Children’s hospitals have no overall ratings in this dataset, so they are included in hospital count, emergency service, and missingness analysis, but excluded from rating ranking comparisons.

National comparison fields also contain missing values. Missingness is analyzed directly so quality domain comparisons are not interpreted without context.

## Planned reporting work

The SQL outputs will later be used for Excel reporting and Power BI dashboarding.

Planned reporting outputs include:

- State-level summary tables
- Ownership-level summary tables
- Hospital type summary tables
- Quality domain comparison summaries
- Rating ranking tables using the sample-adjusted rating score