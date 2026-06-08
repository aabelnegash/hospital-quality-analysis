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
→ SQL summary views
→ Python export script
→ Excel report workbook
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

## Excel reporting

The Excel workbook is located in:

```text
excel/hospital_quality_report.xlsx
```

The workbook uses the exported SQL output CSV files from `data/output/` and organizes them into a static report and pivot-based analysis workbook.

The Excel workbook includes:

- Imported SQL output tables from the state, ownership, hospital type, and quality-domain analyses
- A front-page report summarizing dataset overview, rating coverage, adjusted rating rankings, and quality-domain findings
- A `Chart Sources` sheet with cleaned mini-tables used to build report visuals
- A `Pivot Analysis` sheet for deeper exploration of state, ownership, and quality-domain patterns
- A slicer-based state quality-domain explorer
- A PivotTable heat map showing below-national-average rates by ownership type and quality domain
- XLOOKUP support to bring sample-adjusted rating scores into the state pivot analysis

The front-page Excel report is organized into four sections:

1. **Dataset Overview**  
   Shows hospital distribution by hospital type, ownership type, and top states by hospital count.

2. **Rating Coverage**  
   Shows where overall hospital ratings are missing across hospital type, ownership type, and selected states.

3. **Rating Rankings**  
   Uses a sample-adjusted rating score to compare states, ownership types, and hospital types while reducing the influence of small rated sample sizes.

4. **Quality Domain Findings**  
   Summarizes below-national-average rates and missing comparison data across CMS quality domains.

The `Pivot Analysis` sheet adds an interactive layer to the workbook. It includes a state-level quality-domain explorer where the selected quality domain changes the PivotTable and PivotChart. The analysis also includes compared record counts and sample-adjusted rating scores to help interpret whether a state result is based on enough available data.

The workbook also includes an ownership-by-quality-domain PivotTable heat map. This shows how below-national-average rates vary across ownership types and CMS quality domains.

The Excel workbook acts as a static analyst report and exploratory workbook. 


## Power BI dashboard

The Power BI dashboard is located in:

```text
powerbi/hospital_quality_dashboard.pbix
```

The dashboard uses the cleaned SQL/Excel reporting outputs to create an interactive Power BI report. The goal of the dashboard is to summarize hospital distribution, rating coverage, adjusted rating rankings, and CMS quality-domain patterns in a more interactive format than the Excel workbook.

The Power BI report includes three pages:

### 1. Overview

The Overview page gives a summary of the hospital dataset.

It includes:

- KPI cards for total hospitals, rated hospitals, and missing ratings
- A slicer-controlled chart that switches between hospital counts by state, ownership type, and hospital type
- A donut chart showing overall rating availability
- A gauge showing average hospital rating on a 0–5 scale

This page is designed to quickly answer:

> What is in the dataset, and how complete is the overall rating data?

### 2. Rating Rankings

The Rating Rankings page focuses on the sample-adjusted rating score used in the SQL analysis.

It includes:

- A scatter plot comparing raw average rating against sample-adjusted rating score
- Bubble sizing based on rated hospital count
- A slicer that switches the analysis level between state, ownership type, and hospital type
- A card showing rated hospital count for the current selection
- A gauge showing the average adjusted score for the selected analysis level
- A chart showing the largest gaps between raw average rating and adjusted score
- A ranking chart showing top groups by sample-adjusted rating score

This page is designed to show how sample-adjusted scores compare with raw average ratings. It also highlights where raw ratings may be less stable because the adjustment gap is larger.

The scatter plot is the main comparison visual. Groups farther right have higher raw average ratings. Groups higher on the chart have higher sample-adjusted scores. Larger bubbles represent more rated hospitals.

The adjustment gap chart helps identify groups where the raw average rating and adjusted score differ the most.

### 3. Quality Domain Analysis

The Quality Domain Analysis page focuses on CMS national comparison fields.

It includes:

- A slicer for analysis level: state, ownership type, or hospital type
- A slicer for quality domain
- A chart showing below-national-average percentage by selected group
- A matrix showing below-average rates by quality domain
- A matrix showing missing comparison percentages by quality domain
- A gauge summarizing the average below-average percentage for the selected filters

This page is designed to answer:

> Which quality domains show weaker performance, and where is comparison data missing?

## Power BI modeling notes

Several helper tables were created in Power BI using DAX to support interactive visuals:

- `Overview_Group_Counts` combines hospital counts by state, ownership type, and hospital type for the slicer-controlled overview chart.
- `Combined_Rating_Rankings` combines state, ownership, and hospital type rating rankings for the rating comparison visuals.
- `Combined_Quality_Domains` combines quality-domain outputs across state, ownership, and hospital type analysis levels.
- `Rating_Availability` supports the donut chart showing rated versus missing hospital ratings.

Basic DAX measures were also used for dashboard metrics such as rating coverage, average raw rating, average adjusted score, and average below-average percentage.

The Power BI dashboard acts as the interactive reporting layer of the project. It builds on the SQL analysis and Excel report by adding slicers, dynamic visuals, gauges, scatter plots, and quality-domain exploration.
````
