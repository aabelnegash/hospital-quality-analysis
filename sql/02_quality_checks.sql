-- Count total rows loaded into the hospitals table.
SELECT
    COUNT(*) AS total_rows
FROM hospitals;

-- Check for missing provider IDs.
SELECT
    COUNT(*) AS missing_provider_ids
FROM hospitals
WHERE provider_id IS NULL
    OR provider_id = '';

-- Check for duplicate provider IDs.
SELECT
    provider_id,
    COUNT(*) AS duplicate_count
FROM hospitals
GROUP BY provider_id
HAVING COUNT(*) > 1;

-- Check for invalid ZIP codes
SELECT
    COUNT(*) AS invalid_zip_codes
FROM hospitals
WHERE zip_code IS NULL
    OR TRIM(zip_code) = ''
    OR LENGTH(TRIM(zip_code)) != 5
    OR TRIM(zip_code) GLOB '*[^0-9]*';

-- Check for invalid phone numbers.
SELECT
    COUNT(*) AS invalid_phone_numbers
FROM hospitals
WHERE phone_number IS NULL
   OR TRIM(phone_number) = ''
   OR LENGTH(TRIM(phone_number)) != 10
   OR TRIM(phone_number) GLOB '*[^0-9]*';

-- Check for invalid state codes.
SELECT
    COUNT(*) AS invalid_state_codes
FROM hospitals
WHERE state IS NULL
   OR state = ''
   OR state NOT GLOB '[A-Z][A-Z]';

-- Count hospitals with missing overall ratings.
SELECT
    COUNT(*) AS missing_hospital_ratings
FROM hospitals
WHERE hospital_overall_rating IS NULL
   OR hospital_overall_rating = '';

-- Show the distribution of hospital overall ratings.
SELECT
    hospital_overall_rating,
    COUNT(*) AS hospital_count
FROM hospitals
GROUP BY hospital_overall_rating
ORDER BY hospital_overall_rating;

-- Check for hospital ratings outside the expected 1-5 range.
SELECT
    COUNT(*) AS invalid_hospital_ratings
FROM hospitals
WHERE hospital_overall_rating IS NOT NULL
  AND hospital_overall_rating != ''
  AND hospital_overall_rating NOT IN ('1', '2', '3', '4', '5', '1.0', '2.0', '3.0', '4.0', '5.0');
