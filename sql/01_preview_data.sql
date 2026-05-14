-- Preview key hospital fields to confirm the table loaded correctly.
SELECT 
    provider_id, 
    hospital_name, 
    city, 
    state, 
    hospital_overall_rating
FROM hospitals
LIMIT 10;

-- Confirm the fill cleaned dataset was loaded into SQLite.
SELECT 
    COUNT(*) AS total_hospitals 
FROM hospitals;

-- Inspect SQLite table schema
PRAGMA table_info(hospitals);