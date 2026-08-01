DROP TABLE IF EXISTS raw.manufacturing_parts;

CREATE TABLE raw.manufacturing_parts (
    item_no INTEGER,
    length NUMERIC(10, 2),
    width NUMERIC(10, 2),
    height NUMERIC(10, 2),
    operator VARCHAR(20)
);

INSERT INTO raw.manufacturing_parts (
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
    operator
FROM public.manufacturing_parts;

