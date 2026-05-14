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