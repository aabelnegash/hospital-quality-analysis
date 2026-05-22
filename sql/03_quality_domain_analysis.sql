-- Convert selected national comparison columns from wide format to long format.
WITH quality_domains AS (
    SELECT
        'Mortality' AS quality_domain,
        mortality_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        'Safety of Care' AS quality_domain,
        safety_of_care_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        'Readmission' AS quality_domain,
        readmission_national_comparison AS national_comparison
    FROM hospitals
    
    UNION ALL

    SELECT
        'Patient Experience' AS quality_domain,
        patient_experience_national_comparison AS national_comparison
    FROM hospitals
    
    UNION ALL

    SELECT
        'Effectiveness of Care' AS quality_domain,
        effectiveness_of_care_national_comparison AS national_comparison
    FROM hospitals
    
    UNION ALL

    SELECT
        'Timeliness of Care' AS quality_domain,
        timeliness_of_care_national_comparison AS national_comparison
    FROM hospitals
    
    UNION ALL

    SELECT
        'Efficient Use of Medical Imaging' AS quality_domain,
        efficient_use_of_medical_imaging_national_comparison AS national_comparison
    FROM hospitals
)
-- Count national comparison categories by quality domain.
SELECT
    quality_domain,
    COALESCE(national_comparison, 'Missing') AS national_comparison,
    COUNT(*) AS hospital_count
FROM quality_domains
GROUP BY
    quality_domain,
    COALESCE(national_comparison, 'Missing')
ORDER BY 
    quality_domain,
    hospital_count DESC;

WITH quality_domains AS (
    SELECT
        'Mortality' AS quality_domain,
        mortality_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        'Safety of Care' AS quality_domain,
        safety_of_care_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        'Readmission' AS quality_domain,
        readmission_national_comparison AS national_comparison
    FROM hospitals
    
    UNION ALL

    SELECT
        'Patient Experience' AS quality_domain,
        patient_experience_national_comparison AS national_comparison
    FROM hospitals
    
    UNION ALL

    SELECT
        'Effectiveness of Care' AS quality_domain,
        effectiveness_of_care_national_comparison AS national_comparison
    FROM hospitals
    
    UNION ALL

    SELECT
        'Timeliness of Care' AS quality_domain,
        timeliness_of_care_national_comparison AS national_comparison
    FROM hospitals
    
    UNION ALL

    SELECT
        'Efficient Use of Medical Imaging' AS quality_domain,
        efficient_use_of_medical_imaging_national_comparison AS national_comparison
    FROM hospitals
)
-- Calculate missing national comparison percentage by quality domain.
SELECT
    quality_domain,
    COUNT(*) AS total_records,
    SUM(CASE WHEN national_comparison IS NULL THEN 1 ELSE 0 END) AS missing_records,
    ROUND(
        100.0 * SUM(CASE WHEN national_comparison IS NULL THEN 1 ELSE 0 END) / COUNT(*), 
        2) AS missing_pct
FROM quality_domains
GROUP BY quality_domain
ORDER BY missing_pct DESC;

WITH quality_domains AS (
    SELECT
        'Mortality' AS quality_domain,
        mortality_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        'Safety of Care' AS quality_domain,
        safety_of_care_national_comparison AS national_comparison
    FROM hospitals

    UNION ALL

    SELECT
        'Readmission' AS quality_domain,
        readmission_national_comparison AS national_comparison
    FROM hospitals
    
    UNION ALL

    SELECT
        'Patient Experience' AS quality_domain,
        patient_experience_national_comparison AS national_comparison
    FROM hospitals
    
    UNION ALL

    SELECT
        'Effectiveness of Care' AS quality_domain,
        effectiveness_of_care_national_comparison AS national_comparison
    FROM hospitals
    
    UNION ALL

    SELECT
        'Timeliness of Care' AS quality_domain,
        timeliness_of_care_national_comparison AS national_comparison
    FROM hospitals
    
    UNION ALL

    SELECT
        'Efficient Use of Medical Imaging' AS quality_domain,
        efficient_use_of_medical_imaging_national_comparison AS national_comparison
    FROM hospitals
)
-- Calculate below-national-average percentage by quality domain using non-missing records.
SELECT
    quality_domain,
    COUNT(*) AS total_compared_records,
    SUM(CASE WHEN national_comparison = 'Below the national average' THEN 1 ELSE 0 END) AS below_average_records,
    ROUND(
        100.0 * SUM(CASE WHEN national_comparison = 'Below the national average' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS below_average_pct
FROM quality_domains
WHERE national_comparison IS NOT NULL
GROUP BY quality_domain
ORDER BY below_average_pct DESC;
