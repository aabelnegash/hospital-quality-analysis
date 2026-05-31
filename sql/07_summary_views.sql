-- Create reusable SQL views for Excel and Power BI reporting outputs.

DROP VIEW IF EXISTS state_summary;
DROP VIEW IF EXISTS state_rating_rankings;
DROP VIEW IF EXISTS ownership_summary;
DROP VIEW IF EXISTS ownership_rating_rankings;
DROP VIEW IF EXISTS hospital_type_summary;
DROP VIEW IF EXISTS hospital_type_rating_rankings;

DROP VIEW IF EXISTS quality_domain_summary;
DROP VIEW IF EXISTS quality_domain_missingness;
DROP VIEW IF EXISTS quality_domain_below_average;
DROP VIEW IF EXISTS state_quality_domain_summary;
DROP VIEW IF EXISTS ownership_quality_domain_summary;
DROP VIEW IF EXISTS hospital_type_quality_domain_summary;
DROP VIEW IF EXISTS quality_domains_long;


-- Reshape national comparison columns from wide format into long format.
CREATE VIEW quality_domains_long AS
SELECT
    state,
    hospital_ownership,
    hospital_type,
    'Mortality' AS quality_domain,
    mortality_national_comparison AS national_comparison
FROM hospitals

UNION ALL

SELECT
    state,
    hospital_ownership,
    hospital_type,
    'Safety of Care' AS quality_domain,
    safety_of_care_national_comparison AS national_comparison
FROM hospitals

UNION ALL

SELECT
    state,
    hospital_ownership,
    hospital_type,
    'Readmission' AS quality_domain,
    readmission_national_comparison AS national_comparison
FROM hospitals

UNION ALL

SELECT
    state,
    hospital_ownership,
    hospital_type,
    'Patient Experience' AS quality_domain,
    patient_experience_national_comparison AS national_comparison
FROM hospitals

UNION ALL

SELECT
    state,
    hospital_ownership,
    hospital_type,
    'Effectiveness of Care' AS quality_domain,
    effectiveness_of_care_national_comparison AS national_comparison
FROM hospitals

UNION ALL

SELECT
    state,
    hospital_ownership,
    hospital_type,
    'Timeliness of Care' AS quality_domain,
    timeliness_of_care_national_comparison AS national_comparison
FROM hospitals

UNION ALL

SELECT
    state,
    hospital_ownership,
    hospital_type,
    'Efficient Use of Medical Imaging' AS quality_domain,
    efficient_use_of_medical_imaging_national_comparison AS national_comparison
FROM hospitals;


-- Summary table by state.
CREATE VIEW state_summary AS
WITH state_summary_base AS (
    SELECT
        state,
        COUNT(*) AS total_hospitals,
        COUNT(hospital_overall_rating) AS rated_hospitals,
        SUM(CASE WHEN emergency_services = 'Yes' THEN 1 ELSE 0 END) AS emergency_hospitals,
        SUM(CASE WHEN hospital_overall_rating IS NULL THEN 1 ELSE 0 END) AS missing_ratings,
        ROUND(AVG(CAST(hospital_overall_rating AS REAL)), 2) AS avg_rating
    FROM hospitals
    WHERE state IS NOT NULL
    GROUP BY state
)
SELECT
    state,
    total_hospitals,
    rated_hospitals,
    emergency_hospitals,
    ROUND(100.0 * emergency_hospitals / total_hospitals, 2) AS emergency_service_pct,
    missing_ratings,
    ROUND(100.0 * missing_ratings / total_hospitals, 2) AS missing_rating_pct,
    avg_rating
FROM state_summary_base;


-- Rating ranking table by state.
CREATE VIEW state_rating_rankings AS
SELECT
    state,
    total_hospitals,
    rated_hospitals,
    avg_rating,
    ROUND(100.0 * rated_hospitals / total_hospitals, 2) AS rating_coverage_pct,
    ROUND(1.0 * rated_hospitals / (rated_hospitals + 20), 3) AS sample_weight,
    ROUND(
        avg_rating * 1.0 * rated_hospitals / (rated_hospitals + 20),
        2
    ) AS sample_adjusted_rating_score
FROM state_summary
WHERE rated_hospitals > 0;


-- Summary table by ownership type.
CREATE VIEW ownership_summary AS
WITH ownership_summary_base AS (
    SELECT
        hospital_ownership,
        COUNT(*) AS total_hospitals,
        COUNT(hospital_overall_rating) AS rated_hospitals,
        SUM(CASE WHEN emergency_services = 'Yes' THEN 1 ELSE 0 END) AS emergency_hospitals,
        SUM(CASE WHEN hospital_overall_rating IS NULL THEN 1 ELSE 0 END) AS missing_ratings,
        ROUND(AVG(CAST(hospital_overall_rating AS REAL)), 2) AS avg_rating
    FROM hospitals
    WHERE hospital_ownership IS NOT NULL
    GROUP BY hospital_ownership
)
SELECT
    hospital_ownership,
    total_hospitals,
    rated_hospitals,
    emergency_hospitals,
    ROUND(100.0 * emergency_hospitals / total_hospitals, 2) AS emergency_service_pct,
    missing_ratings,
    ROUND(100.0 * missing_ratings / total_hospitals, 2) AS missing_rating_pct,
    avg_rating
FROM ownership_summary_base;


-- Rating ranking table by ownership type.
CREATE VIEW ownership_rating_rankings AS
SELECT
    hospital_ownership,
    total_hospitals,
    rated_hospitals,
    avg_rating,
    ROUND(100.0 * rated_hospitals / total_hospitals, 2) AS rating_coverage_pct,
    ROUND(1.0 * rated_hospitals / (rated_hospitals + 20), 3) AS sample_weight,
    ROUND(
        avg_rating * 1.0 * rated_hospitals / (rated_hospitals + 20),
        2
    ) AS sample_adjusted_rating_score
FROM ownership_summary
WHERE rated_hospitals > 0;


-- Summary table by hospital type.
CREATE VIEW hospital_type_summary AS
WITH hospital_type_summary_base AS (
    SELECT
        hospital_type,
        COUNT(*) AS total_hospitals,
        COUNT(hospital_overall_rating) AS rated_hospitals,
        SUM(CASE WHEN emergency_services = 'Yes' THEN 1 ELSE 0 END) AS emergency_hospitals,
        SUM(CASE WHEN hospital_overall_rating IS NULL THEN 1 ELSE 0 END) AS missing_ratings,
        ROUND(AVG(CAST(hospital_overall_rating AS REAL)), 2) AS avg_rating
    FROM hospitals
    WHERE hospital_type IS NOT NULL
    GROUP BY hospital_type
)
SELECT
    hospital_type,
    total_hospitals,
    rated_hospitals,
    emergency_hospitals,
    ROUND(100.0 * emergency_hospitals / total_hospitals, 2) AS emergency_service_pct,
    missing_ratings,
    ROUND(100.0 * missing_ratings / total_hospitals, 2) AS missing_rating_pct,
    avg_rating
FROM hospital_type_summary_base;


-- Rating ranking table by hospital type.
CREATE VIEW hospital_type_rating_rankings AS
SELECT
    hospital_type,
    total_hospitals,
    rated_hospitals,
    avg_rating,
    ROUND(100.0 * rated_hospitals / total_hospitals, 2) AS rating_coverage_pct,
    ROUND(1.0 * rated_hospitals / (rated_hospitals + 20), 3) AS sample_weight,
    ROUND(
        avg_rating * 1.0 * rated_hospitals / (rated_hospitals + 20),
        2
    ) AS sample_adjusted_rating_score
FROM hospital_type_summary
WHERE rated_hospitals > 0;


-- Count national comparison categories by quality domain.
CREATE VIEW quality_domain_summary AS
SELECT
    quality_domain,
    COALESCE(national_comparison, 'Missing') AS national_comparison,
    COUNT(*) AS hospital_count
FROM quality_domains_long
GROUP BY
    quality_domain,
    COALESCE(national_comparison, 'Missing');


-- Missing national comparison percentage by quality domain.
CREATE VIEW quality_domain_missingness AS
SELECT
    quality_domain,
    COUNT(*) AS total_records,
    SUM(CASE WHEN national_comparison IS NULL THEN 1 ELSE 0 END) AS missing_records,
    ROUND(
        100.0 * SUM(CASE WHEN national_comparison IS NULL THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS missing_pct
FROM quality_domains_long
GROUP BY quality_domain;


-- Below-national-average percentage by quality domain using non-missing records.
CREATE VIEW quality_domain_below_average AS
SELECT
    quality_domain,
    COUNT(*) AS total_compared_records,
    SUM(CASE WHEN national_comparison = 'Below the national average' THEN 1 ELSE 0 END) AS below_average_records,
    ROUND(
        100.0 * SUM(CASE WHEN national_comparison = 'Below the national average' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS below_average_pct
FROM quality_domains_long
WHERE national_comparison IS NOT NULL
GROUP BY quality_domain;


-- Quality-domain comparison summary by state and domain.
CREATE VIEW state_quality_domain_summary AS
SELECT
    state,
    quality_domain,
    COUNT(*) AS total_quality_domain_records,
    COUNT(national_comparison) AS compared_records,
    SUM(CASE WHEN national_comparison IS NULL THEN 1 ELSE 0 END) AS missing_records,
    ROUND(
        100.0 * SUM(CASE WHEN national_comparison IS NULL THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS missing_pct,
    SUM(CASE WHEN national_comparison = 'Below the national average' THEN 1 ELSE 0 END) AS below_average_records,
    ROUND(
        100.0 * SUM(CASE WHEN national_comparison = 'Below the national average' THEN 1 ELSE 0 END) / NULLIF(COUNT(national_comparison), 0),
        2
    ) AS below_average_pct
FROM quality_domains_long
WHERE state IS NOT NULL
GROUP BY
    state,
    quality_domain;


-- Quality-domain comparison summary by ownership type and domain.
CREATE VIEW ownership_quality_domain_summary AS
SELECT
    hospital_ownership,
    quality_domain,
    COUNT(*) AS total_quality_domain_records,
    COUNT(national_comparison) AS compared_records,
    SUM(CASE WHEN national_comparison IS NULL THEN 1 ELSE 0 END) AS missing_records,
    ROUND(
        100.0 * SUM(CASE WHEN national_comparison IS NULL THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS missing_pct,
    SUM(CASE WHEN national_comparison = 'Below the national average' THEN 1 ELSE 0 END) AS below_average_records,
    ROUND(
        100.0 * SUM(CASE WHEN national_comparison = 'Below the national average' THEN 1 ELSE 0 END) / NULLIF(COUNT(national_comparison), 0),
        2
    ) AS below_average_pct
FROM quality_domains_long
WHERE hospital_ownership IS NOT NULL
GROUP BY
    hospital_ownership,
    quality_domain;


-- Quality-domain comparison summary by hospital type and domain.
CREATE VIEW hospital_type_quality_domain_summary AS
SELECT
    hospital_type,
    quality_domain,
    COUNT(*) AS total_quality_domain_records,
    COUNT(national_comparison) AS compared_records,
    SUM(CASE WHEN national_comparison IS NULL THEN 1 ELSE 0 END) AS missing_records,
    ROUND(
        100.0 * SUM(CASE WHEN national_comparison IS NULL THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS missing_pct,
    SUM(CASE WHEN national_comparison = 'Below the national average' THEN 1 ELSE 0 END) AS below_average_records,
    ROUND(
        100.0 * SUM(CASE WHEN national_comparison = 'Below the national average' THEN 1 ELSE 0 END) / NULLIF(COUNT(national_comparison), 0),
        2
    ) AS below_average_pct
FROM quality_domains_long
WHERE hospital_type IS NOT NULL
GROUP BY
    hospital_type,
    quality_domain;