-- =====================================================
-- Manufacturing SPC Project
-- Compare SPC monitoring methods
--
-- Method 1:
-- Inclusive window
-- Current measurement + previous four measurements
--
-- Method 2:
-- Previous-only window
-- Previous five measurements only
-- =====================================================


-- -----------------------------------------------------
-- 1. Overall alert counts by method
-- -----------------------------------------------------

SELECT
    'inclusive' AS method,
    COUNT(*) AS analyzed_items,

    COUNT(*) FILTER (
        WHERE length_alert
    ) AS length_alerts,

    COUNT(*) FILTER (
        WHERE width_alert
    ) AS width_alerts,

    COUNT(*) FILTER (
        WHERE height_alert
    ) AS height_alerts,

    COUNT(*) FILTER (
        WHERE overall_alert
    ) AS overall_alerts

FROM analytics.manufacturing_spc_alerts_inclusive


UNION ALL


SELECT
    'previous_only' AS method,
    COUNT(*) AS analyzed_items,

    COUNT(*) FILTER (
        WHERE length_alert
    ) AS length_alerts,

    COUNT(*) FILTER (
        WHERE width_alert
    ) AS width_alerts,

    COUNT(*) FILTER (
        WHERE height_alert
    ) AS height_alerts,

    COUNT(*) FILTER (
        WHERE overall_alert
    ) AS overall_alerts

FROM analytics.manufacturing_spc_alerts_previous_only;


-- -----------------------------------------------------
-- 2. Overall alert percentage by method
-- -----------------------------------------------------

SELECT
    'inclusive' AS method,

    COUNT(*) AS analyzed_items,

    COUNT(*) FILTER (
        WHERE overall_alert
    ) AS alert_items,

    ROUND(
        100.0
        * COUNT(*) FILTER (WHERE overall_alert)
        / COUNT(*),
        2
    ) AS alert_percentage

FROM analytics.manufacturing_spc_alerts_inclusive


UNION ALL


SELECT
    'previous_only' AS method,

    COUNT(*) AS analyzed_items,

    COUNT(*) FILTER (
        WHERE overall_alert
    ) AS alert_items,

    ROUND(
        100.0
        * COUNT(*) FILTER (WHERE overall_alert)
        / COUNT(*),
        2
    ) AS alert_percentage

FROM analytics.manufacturing_spc_alerts_previous_only;



-- -----------------------------------------------------
-- 3. Products classified differently by the two methods
-- -----------------------------------------------------

SELECT
    i.item_no,
    i.operator,

    i.overall_alert AS inclusive_alert,
    p.overall_alert AS previous_only_alert,

    i.length_alert AS inclusive_length_alert,
    p.length_alert AS previous_only_length_alert,

    i.width_alert AS inclusive_width_alert,
    p.width_alert AS previous_only_width_alert,

    i.height_alert AS inclusive_height_alert,
    p.height_alert AS previous_only_height_alert

FROM analytics.manufacturing_spc_alerts_inclusive AS i

INNER JOIN analytics.manufacturing_spc_alerts_previous_only AS p
    ON i.item_no = p.item_no
   AND i.operator = p.operator

WHERE i.overall_alert
      IS DISTINCT FROM p.overall_alert

ORDER BY i.item_no;