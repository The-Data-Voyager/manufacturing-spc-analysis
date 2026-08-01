-- =====================================================
-- Manufacturing SPC Project
-- Operator Performance Analysis
--
-- Monitoring method:
-- Previous five measurements only
-- =====================================================


-- -----------------------------------------------------
-- 1. Alert summary by operator
-- -----------------------------------------------------

SELECT
    operator,

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
    ) AS overall_alerts,

    ROUND(
        100.0
        * COUNT(*) FILTER (WHERE overall_alert)
        / COUNT(*),
        2
    ) AS alert_rate_percentage

FROM analytics.manufacturing_spc_alerts_previous_only

GROUP BY operator

ORDER BY alert_rate_percentage DESC,
         operator;



-- -----------------------------------------------------
-- 2. Rank operators by overall alert rate
-- -----------------------------------------------------

WITH operator_summary AS (
    SELECT
        operator,

        COUNT(*) AS analyzed_items,

        COUNT(*) FILTER (
            WHERE overall_alert
        ) AS overall_alerts,

        ROUND(
            100.0
            * COUNT(*) FILTER (WHERE overall_alert)
            / COUNT(*),
            2
        ) AS alert_rate_percentage

    FROM analytics.manufacturing_spc_alerts_previous_only

    GROUP BY operator
)

SELECT
    operator,
    analyzed_items,
    overall_alerts,
    alert_rate_percentage,

    DENSE_RANK() OVER (
        ORDER BY alert_rate_percentage DESC
    ) AS alert_rate_rank

FROM operator_summary

ORDER BY alert_rate_rank,
         operator;

-- -----------------------------------------------------
-- 3. Overall alert count by dimension
-- -----------------------------------------------------

SELECT
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
-- 4. Dominant alert dimension by operator
-- -----------------------------------------------------

WITH operator_dimension_counts AS (
    SELECT
        operator,

        COUNT(*) FILTER (
            WHERE length_alert
        ) AS length_alerts,

        COUNT(*) FILTER (
            WHERE width_alert
        ) AS width_alerts,

        COUNT(*) FILTER (
            WHERE height_alert
        ) AS height_alerts

    FROM analytics.manufacturing_spc_alerts_previous_only

    GROUP BY operator
)

SELECT
    operator,
    length_alerts,
    width_alerts,
    height_alerts,

    GREATEST(
        length_alerts,
        width_alerts,
        height_alerts
    ) AS highest_dimension_alert_count,

	CASE
	    WHEN length_alerts = width_alerts
	     AND width_alerts = height_alerts
	        THEN 'tie: length / width / height'
	
	    WHEN length_alerts = width_alerts
	     AND length_alerts > height_alerts
	        THEN 'tie: length / width'
	
	    WHEN length_alerts = height_alerts
	     AND length_alerts > width_alerts
	        THEN 'tie: length / height'
	
	    WHEN width_alerts = height_alerts
	     AND width_alerts > length_alerts
	        THEN 'tie: width / height'
	
	    WHEN length_alerts > width_alerts
	     AND length_alerts > height_alerts
	        THEN 'length'
	
	    WHEN width_alerts > length_alerts
	     AND width_alerts > height_alerts
	        THEN 'width'
	
	    ELSE 'height'
	END AS dominant_alert_dimension

FROM operator_dimension_counts

ORDER BY highest_dimension_alert_count DESC,
         operator;



-- -----------------------------------------------------
-- 5. Highest-alert-rate operator
-- -----------------------------------------------------

SELECT
    operator,

    COUNT(*) AS analyzed_items,

    COUNT(*) FILTER (
        WHERE overall_alert
    ) AS overall_alerts,

    ROUND(
        100.0
        * COUNT(*) FILTER (WHERE overall_alert)
        / COUNT(*),
        2
    ) AS alert_rate_percentage

FROM analytics.manufacturing_spc_alerts_previous_only

GROUP BY operator

ORDER BY alert_rate_percentage DESC

LIMIT 1;