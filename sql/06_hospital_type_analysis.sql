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
    avg_rating,
    emergency_hospitals,
    ROUND(100.0 * emergency_hospitals / total_hospitals, 2) AS emergency_service_pct,
    missing_ratings,
    ROUND(100.0 * missing_ratings / total_hospitals, 2) AS missing_rating_pct
FROM hospital_type_summary
ORDER BY total_hospitals DESC;