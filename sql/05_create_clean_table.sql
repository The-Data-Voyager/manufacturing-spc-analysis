-- =====================================================
-- Manufacturing SPC Project
-- Create cleaned manufacturing table
--
-- Source:
--     raw.manufacturing_parts
--
-- Target:
--     analytics.manufacturing_parts_clean
-- =====================================================


DROP TABLE IF EXISTS analytics.manufacturing_parts_clean;


CREATE TABLE analytics.manufacturing_parts_clean (
    item_no INTEGER PRIMARY KEY,

    length NUMERIC(10, 2) NOT NULL
        CHECK (length > 0),

    width NUMERIC(10, 2) NOT NULL
        CHECK (width > 0),

    height NUMERIC(10, 2) NOT NULL
        CHECK (height > 0),

    operator VARCHAR(20) NOT NULL
        CHECK (TRIM(operator) <> '')
);


INSERT INTO analytics.manufacturing_parts_clean (
    item_no,
    length,
    width,
    height,
    operator
)
SELECT
    item_no,
    length,
    width,
    height,
    TRIM(operator) AS operator
FROM raw.manufacturing_parts;


