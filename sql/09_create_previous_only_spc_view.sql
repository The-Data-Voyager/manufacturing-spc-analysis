-- =====================================================
-- Manufacturing SPC Project
-- Previous-only SPC analysis
--
-- Source:
--     analytics.manufacturing_parts_clean
--
-- Reference window:
--     Previous five measurements for the same operator
--     Current measurement is excluded
-- =====================================================

CREATE OR REPLACE VIEW
    analytics.manufacturing_spc_alerts_previous_only AS

WITH previous_statistics AS (
    SELECT
        item_no,
        operator,
        length,
        width,
        height,

        ROW_NUMBER() OVER (
            PARTITION BY operator
            ORDER BY item_no
        ) AS row_number,

        COUNT(*) OVER (
            PARTITION BY operator
            ORDER BY item_no
            ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING
        ) AS reference_count,

        AVG(length) OVER (
            PARTITION BY operator
            ORDER BY item_no
            ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING
        ) AS avg_length,

        STDDEV_SAMP(length) OVER (
            PARTITION BY operator
            ORDER BY item_no
            ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING
        ) AS stddev_length,

        AVG(width) OVER (
            PARTITION BY operator
            ORDER BY item_no
            ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING
        ) AS avg_width,

        STDDEV_SAMP(width) OVER (
            PARTITION BY operator
            ORDER BY item_no
            ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING
        ) AS stddev_width,

        AVG(height) OVER (
            PARTITION BY operator
            ORDER BY item_no
            ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING
        ) AS avg_height,

        STDDEV_SAMP(height) OVER (
            PARTITION BY operator
            ORDER BY item_no
            ROWS BETWEEN 5 PRECEDING AND 1 PRECEDING
        ) AS stddev_height

    FROM analytics.manufacturing_parts_clean
),


control_limits AS (
    SELECT
        item_no,
        operator,
        row_number,

        length,
        avg_length,
        stddev_length,
        avg_length
            + 3 * (stddev_length / SQRT(5.0)) AS length_ucl,
        avg_length
            - 3 * (stddev_length / SQRT(5.0)) AS length_lcl,

        width,
        avg_width,
        stddev_width,
        avg_width
            + 3 * (stddev_width / SQRT(5.0)) AS width_ucl,
        avg_width
            - 3 * (stddev_width / SQRT(5.0)) AS width_lcl,

        height,
        avg_height,
        stddev_height,
        avg_height
            + 3 * (stddev_height / SQRT(5.0)) AS height_ucl,
        avg_height
            - 3 * (stddev_height / SQRT(5.0)) AS height_lcl

    FROM previous_statistics
    WHERE reference_count = 5
),


dimension_alerts AS (
    SELECT
        item_no,
        operator,
        row_number,

        length,
        avg_length,
        stddev_length,
        length_ucl,
        length_lcl,
        length > length_ucl
            OR length < length_lcl AS length_alert,

        width,
        avg_width,
        stddev_width,
        width_ucl,
        width_lcl,
        width > width_ucl
            OR width < width_lcl AS width_alert,

        height,
        avg_height,
        stddev_height,
        height_ucl,
        height_lcl,
        height > height_ucl
            OR height < height_lcl AS height_alert

    FROM control_limits
)


SELECT
    item_no,
    operator,
    row_number,

    length,
    avg_length,
    stddev_length,
    length_ucl,
    length_lcl,
    length_alert,

    width,
    avg_width,
    stddev_width,
    width_ucl,
    width_lcl,
    width_alert,

    height,
    avg_height,
    stddev_height,
    height_ucl,
    height_lcl,
    height_alert,

    length_alert
        OR width_alert
        OR height_alert AS overall_alert

FROM dimension_alerts
ORDER BY item_no;

