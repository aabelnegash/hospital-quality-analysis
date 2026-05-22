-- Count hospitals by state.
SELECT 
    state,
    COUNT(*) AS total_hospitals
FROM hospitals
GROUP BY state
ORDER BY total_hospitals DESC;

-- Calculate average hospital rating by state for states with at least 20 rated hospitals.
SELECT
    state,
    COUNT(*) AS rated_hospitals,
    ROUND(AVG(CAST(hospital_overall_rating AS REAL)), 2) AS avg_rating
FROM hospitals
WHERE hospital_overall_rating IS NOT NULL
GROUP BY state
HAVING COUNT(*) >= 20
ORDER BY avg_rating DESC;

-- Calculate percentage of hospitals that provide emergency services by state for states with at least 20 rated hospitals.
SELECT
    state,
    COUNT(*) AS total_hospitals,
    SUM(CASE WHEN emergency_services = 'Yes' THEN 1 ELSE 0 END) AS emergency_hospitals,
    ROUND(
        100.0 * SUM(CASE WHEN emergency_services = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2 
        ) AS emergency_service_pct
FROM hospitals
GROUP BY state
HAVING COUNT(*) >= 20
ORDER BY emergency_service_pct DESC;

-- Calculate the percentage of hospitals within each state that are missing overall ratings.
SELECT
    state,
    COUNT(*) AS total_hospitals,
    SUM(CASE WHEN hospital_overall_rating IS NULL THEN 1 ELSE 0 END) AS missing_ratings,
    ROUND(
        100.0 * SUM(CASE WHEN hospital_overall_rating IS NULL THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS missing_rating_pct
FROM hospitals
GROUP BY state
HAVING COUNT(*) >= 20
ORDER BY missing_rating_pct DESC;

