-- Summarize key hospital metrics by state.
WITH state_summary AS(
    SELECT
        state,
        COUNT(*) AS total_hospitals,
        SUM(CASE WHEN hospital_overall_rating IS NOT NULL THEN 1 ELSE 0 END) AS rated_hospitals,
        ROUND(AVG(CAST(hospital_overall_rating AS REAL)), 2) AS avg_rating,
        SUM(CASE WHEN emergency_services = 'Yes' THEN 1 ELSE 0 END) AS emergency_hospitals,
        SUM(CASE WHEN hospital_overall_rating IS NULL THEN 1 ELSE 0 END) AS missing_ratings
    FROM hospitals
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
FROM state_summary
ORDER BY total_hospitals DESC;

-- Rank states by rating strength while penalizing small rated sample sizes.
WITH state_summary AS(
    SELECT
        state,
        COUNT(*) AS total_hospitals,
        SUM(CASE WHEN hospital_overall_rating IS NOT NULL THEN 1 ELSE 0 END) AS rated_hospitals,
        ROUND(AVG(CAST(hospital_overall_rating AS REAL)), 2) AS avg_rating,
        SUM(CASE WHEN emergency_services = 'Yes' THEN 1 ELSE 0 END) AS emergency_hospitals,
        SUM(CASE WHEN hospital_overall_rating IS NULL THEN 1 ELSE 0 END) AS missing_ratings
    FROM hospitals
    GROUP BY state
) 
SELECT 
    state,
    total_hospitals,
    rated_hospitals,
    ROUND(100.0 * rated_hospitals / total_hospitals, 2) AS rating_coverage_pct,
    ROUND(1.0 * rated_hospitals / (rated_hospitals + 20), 3) AS sample_weight,
    ROUND(
        avg_rating * 1.0 * rated_hospitals / (rated_hospitals  + 20),
        2) AS sample_adjusted_rating_score,
    avg_rating
FROM state_summary
WHERE rated_hospitals > 0
ORDER BY sample_adjusted_rating_score DESC;

-- Calculate below-national-average quality comparison percentage by state.
WITH state_quality_domains AS (
    SELECT
        state,
        'Mortality' AS quality_domain,
        mortality_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        state,
        'Safety of Care' AS quality_domain,
        safety_of_care_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        state,
        'Readmission' AS quality_domain,
        readmission_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        state,
        'Patient Experience' AS quality_domain,
        patient_experience_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        state,
        'Effectiveness of Care' AS quality_domain,
        effectiveness_of_care_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        state,
        'Timeliness of Care' AS quality_domain,
        timeliness_of_care_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        state,
        'Efficient Use of Medical Imaging' AS quality_domain,
        efficient_use_of_medical_imaging_national_comparison AS national_comparison
    FROM hospitals
)
SELECT
    state,
    COUNT(*) AS total_compared_records,
    SUM(CASE WHEN national_comparison = 'Below the national average' THEN 1 ELSE 0 END) AS below_average_records,
    ROUND(
        100.0 * SUM(CASE WHEN national_comparison = 'Below the national average' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS below_average_pct
FROM state_quality_domains
WHERE national_comparison IS NOT NULL
GROUP BY state
HAVING COUNT(*) >= 50
ORDER BY below_average_pct DESC;