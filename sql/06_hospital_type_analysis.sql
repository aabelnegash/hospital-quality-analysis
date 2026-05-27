-- Summarize key hospital metrics by hospital type
WITH hospital_type_summary AS (
    SELECT
        hospital_type,
        COUNT(*) AS total_hospitals,
        COUNT(hospital_overall_rating) AS rated_hospitals,
        ROUND(AVG(CAST(hospital_overall_rating AS REAL)), 2) AS avg_rating,
        SUM(CASE WHEN emergency_services = 'Yes' THEN 1 ELSE 0 END) AS emergency_hospitals,
        SUM(CASE WHEN hospital_overall_rating IS NULL THEN 1 ELSE 0 END) AS missing_ratings
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
FROM hospital_type_summary
ORDER BY total_hospitals DESC;

-- Rank hospital types by rating strength while penalizing small rated sample sizes.
WITH hospital_type_summary AS (
    SELECT
        hospital_type,
        COUNT(*) AS total_hospitals,
        COUNT(hospital_overall_rating) AS rated_hospitals,
        ROUND(AVG(CAST(hospital_overall_rating AS REAL)), 2) AS avg_rating,
        SUM(CASE WHEN emergency_services = 'Yes' THEN 1 ELSE 0 END) AS emergency_hospitals,
        SUM(CASE WHEN hospital_overall_rating IS NULL THEN 1 ELSE 0 END) AS missing_ratings
    FROM hospitals
    WHERE hospital_type IS NOT NULL
    GROUP BY hospital_type
)
SELECT 
    hospital_type,
    total_hospitals,
    rated_hospitals,
    ROUND(100.0 * rated_hospitals / total_hospitals, 2) AS rating_coverage_pct,
    ROUND(1.0 * rated_hospitals / (rated_hospitals + 20), 3) AS sample_weight,
    ROUND(
        avg_rating * 1.0 * rated_hospitals / (rated_hospitals  + 20),
        2) AS sample_adjusted_rating_score,
    avg_rating
FROM hospital_type_summary
WHERE rated_hospitals > 0
ORDER BY sample_adjusted_rating_score DESC;

-- Calculate missing quality comparison percentage by hospital type.
WITH hospital_type_quality_domains AS (
    SELECT
        hospital_type,
        'Mortality' AS quality_domain,
        mortality_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        hospital_type,
        'Safety of Care' AS quality_domain,
        safety_of_care_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        hospital_type,
        'Readmission' AS quality_domain,
        readmission_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        hospital_type,
        'Patient Experience' AS quality_domain,
        patient_experience_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        hospital_type,
        'Effectiveness of Care' AS quality_domain,
        effectiveness_of_care_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        hospital_type,
        'Timeliness of Care' AS quality_domain,
        timeliness_of_care_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        hospital_type,
        'Efficient Use of Medical Imaging' AS quality_domain,
        efficient_use_of_medical_imaging_national_comparison AS national_comparison
    FROM hospitals
)
SELECT
    hospital_type,
    COUNT(*) AS total_quality_domain_records,
    SUM(CASE WHEN national_comparison IS NULL THEN 1 ELSE 0 END) AS missing_quality_domain_records,
    ROUND(
        100.0 * SUM(CASE WHEN national_comparison IS NULL THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS missing_quality_domain_pct
FROM hospital_type_quality_domains
WHERE hospital_type IS NOT NULL
GROUP BY hospital_type
ORDER BY missing_quality_domain_pct DESC;