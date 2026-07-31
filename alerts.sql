WITH rolling_calculations AS (
    SELECT
        item_no,
        operator,
        height,

        ROW_NUMBER() OVER (
            PARTITION BY operator
            ORDER BY item_no
        ) AS row_number,

        COUNT(*) OVER (
            PARTITION BY operator
            ORDER BY item_no
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        ) AS window_count,

        AVG(height) OVER (
            PARTITION BY operator
            ORDER BY item_no
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        ) AS avg_height,

        STDDEV_SAMP(height) OVER (
            PARTITION BY operator
            ORDER BY item_no
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        ) AS stddev_height

    FROM manufacturing_parts
),

control_limits AS (
    SELECT
        item_no,
        operator,
        row_number,
        height,
        avg_height,
        stddev_height,
        avg_height + 3 * (stddev_height / SQRT(5)) AS ucl,
        avg_height - 3 * (stddev_height / SQRT(5)) AS lcl
    FROM rolling_calculations
    WHERE window_count = 5
),

alerts AS (
    SELECT
        item_no,
        operator,
        row_number,
        height,
        avg_height,
        stddev_height,
        ucl,
        lcl,
        height > ucl OR height < lcl AS alert
    FROM control_limits
)

SELECT
    alert,
    COUNT(*) AS number_of_measurements
FROM alerts
GROUP BY alert
ORDER BY alert;