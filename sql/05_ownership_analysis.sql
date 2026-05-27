-- Summarize key hospital metrics by ownership type.
WITH ownership_summary AS (
    SELECT
        hospital_ownership,
        COUNT(*) AS total_hospitals,
        COUNT(hospital_overall_rating) AS rated_hospitals,
        ROUND(AVG(CAST(hospital_overall_rating AS REAL)), 2) AS avg_rating,
        SUM(CASE WHEN emergency_services = 'Yes'  THEN 1 ELSE 0 END) AS emergency_hospitals,
        SUM(CASE WHEN hospital_overall_rating IS NULL THEN 1 ELSE 0 END) AS missing_ratings
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
FROM ownership_summary
ORDER BY total_hospitals DESC;

-- Rank ownership types by rating strength while penalizing small rated sample sizes.
WITH ownership_summary AS (
    SELECT
        hospital_ownership,
        COUNT(*) AS total_hospitals,
        COUNT(hospital_overall_rating) AS rated_hospitals,
        ROUND(AVG(CAST(hospital_overall_rating AS REAL)), 2) AS avg_rating,
        SUM(CASE WHEN emergency_services = 'Yes'  THEN 1 ELSE 0 END) AS emergency_hospitals,
        SUM(CASE WHEN hospital_overall_rating IS NULL THEN 1 ELSE 0 END) AS missing_ratings
    FROM hospitals
    WHERE hospital_ownership IS NOT NULL
    GROUP BY hospital_ownership
)
SELECT 
    hospital_ownership,
    total_hospitals,
    rated_hospitals,
    ROUND(100.0 * rated_hospitals / total_hospitals, 2) AS rating_coverage_pct,
    ROUND(1.0 * rated_hospitals / (rated_hospitals + 20), 3) AS sample_weight,
    ROUND(
        avg_rating * 1.0 * rated_hospitals / (rated_hospitals  + 20),
        2) AS sample_adjusted_rating_score,
    avg_rating
FROM ownership_summary
WHERE rated_hospitals > 0
ORDER BY sample_adjusted_rating_score DESC;

-- Calculate below-national-average quality comparison percentage by ownership type.
WITH ownership_quality_domains AS (
    SELECT
        hospital_ownership,
        'Mortality' AS quality_domain,
        mortality_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        hospital_ownership,
        'Safety of Care' AS quality_domain,
        safety_of_care_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        hospital_ownership,
        'Readmission' AS quality_domain,
        readmission_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        hospital_ownership,
        'Patient Experience' AS quality_domain,
        patient_experience_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        hospital_ownership,
        'Effectiveness of Care' AS quality_domain,
        effectiveness_of_care_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        hospital_ownership,
        'Timeliness of Care' AS quality_domain,
        timeliness_of_care_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        hospital_ownership,
        'Efficient Use of Medical Imaging' AS quality_domain,
        efficient_use_of_medical_imaging_national_comparison AS national_comparison
    FROM hospitals
)
SELECT
    hospital_ownership,
    COUNT(*) AS total_compared_records,
    SUM(CASE WHEN national_comparison = 'Below the national average' THEN 1 ELSE 0 END) AS below_average_records,
    ROUND(
        100.0 * SUM(CASE WHEN national_comparison = 'Below the national average' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS below_average_pct
FROM ownership_quality_domains
WHERE hospital_ownership IS NOT NULL
  AND national_comparison IS NOT NULL
GROUP BY hospital_ownership
HAVING COUNT(*) >= 50
ORDER BY below_average_pct DESC;