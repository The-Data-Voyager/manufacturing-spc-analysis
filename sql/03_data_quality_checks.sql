-- =====================================================
-- Manufacturing SPC Project
-- Data Quality Checks
-- Source table: raw.manufacturing_parts
-- =====================================================


-- 1. Total row count
SELECT
    COUNT(*) AS total_rows
FROM raw.manufacturing_parts;


-- 2. Missing-value check
SELECT
    COUNT(*) FILTER (
        WHERE item_no IS NULL
    ) AS missing_item_no,

    COUNT(*) FILTER (
        WHERE length IS NULL
    ) AS missing_length,

    COUNT(*) FILTER (
        WHERE width IS NULL
    ) AS missing_width,

    COUNT(*) FILTER (
        WHERE height IS NULL
    ) AS missing_height,

    COUNT(*) FILTER (
        WHERE operator IS NULL
    ) AS missing_operator

FROM raw.manufacturing_parts;


-- 3. Duplicate item numbers
SELECT
    item_no,
    COUNT(*) AS occurrence_count
FROM raw.manufacturing_parts
GROUP BY item_no
HAVING COUNT(*) > 1
ORDER BY item_no;


-- 4. Invalid dimensions
SELECT
    item_no,
    length,
    width,
    height,
    operator
FROM raw.manufacturing_parts
WHERE length <= 0
   OR width <= 0
   OR height <= 0
ORDER BY item_no;


-- 5. Missing or blank operators
SELECT
    item_no,
    operator
FROM raw.manufacturing_parts
WHERE operator IS NULL
   OR TRIM(operator) = ''
ORDER BY item_no;


-- 6. Number of rows per operator
SELECT
    operator,
    COUNT(*) AS item_count
FROM raw.manufacturing_parts
GROUP BY operator
ORDER BY operator;


-- 7. Dimension ranges
SELECT
    MIN(length) AS minimum_length,
    MAX(length) AS maximum_length,
    MIN(width) AS minimum_width,
    MAX(width) AS maximum_width,
    MIN(height) AS minimum_height,
    MAX(height) AS maximum_height
FROM raw.manufacturing_parts;


-- 8. Distinct operator count
SELECT
    COUNT(DISTINCT operator) AS operator_count
FROM raw.manufacturing_parts;

-- =====================================================
-- Consolidated data-quality summary
-- =====================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE item_no IS NULL
    ) AS missing_item_no,

    COUNT(*) FILTER (
        WHERE length IS NULL
    ) AS missing_length,

    COUNT(*) FILTER (
        WHERE width IS NULL
    ) AS missing_width,

    COUNT(*) FILTER (
        WHERE height IS NULL
    ) AS missing_height,

    COUNT(*) FILTER (
        WHERE operator IS NULL
           OR TRIM(operator) = ''
    ) AS missing_or_blank_operator,

    COUNT(DISTINCT TRIM(operator))
        FILTER (
            WHERE operator IS NOT NULL
              AND TRIM(operator) <> ''
        ) AS distinct_operator_count,

    MIN(length) AS minimum_length,
    MAX(length) AS maximum_length,

    MIN(width) AS minimum_width,
    MAX(width) AS maximum_width,

    MIN(height) AS minimum_height,
    MAX(height) AS maximum_height,

    COUNT(*) FILTER (
        WHERE length <= 0
           OR width <= 0
           OR height <= 0
    ) AS invalid_dimension_rows,

    (
        SELECT COUNT(*)
        FROM (
            SELECT
                item_no
            FROM raw.manufacturing_parts
            GROUP BY item_no
            HAVING COUNT(*) > 1
        ) AS duplicate_items
    ) AS duplicated_item_numbers

FROM raw.manufacturing_parts;