-- =============================================================
-- 02_signal_analysis.sql
-- Project  : Telecom Network Quality Intelligence
-- Purpose  : Deep signal strength analysis
-- Date     : 2026-09-27
-- =============================================================

USE telecom_nqi;

-- =============================================================
-- QUERY 01: Signal Quality by Environment
-- =============================================================
SELECT
    environment,
    COUNT(*)                                                AS total_records,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm,
    ROUND(MIN(signal_strength_dbm), 2)                     AS min_signal_dbm,
    ROUND(MAX(signal_strength_dbm), 2)                     AS max_signal_dbm,
    ROUND(STDDEV_SAMP(signal_strength_dbm), 2)             AS stddev_signal,
    SUM(CASE WHEN signal_quality_category = 'Excellent' THEN 1 ELSE 0 END) AS cnt_excellent,
    SUM(CASE WHEN signal_quality_category = 'Good'      THEN 1 ELSE 0 END) AS cnt_good,
    SUM(CASE WHEN signal_quality_category = 'Fair'      THEN 1 ELSE 0 END) AS cnt_fair,
    SUM(CASE WHEN signal_quality_category = 'Poor'      THEN 1 ELSE 0 END) AS cnt_poor,
    ROUND(SUM(CASE WHEN signal_quality_category IN ('Fair','Poor') THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 2)                             AS pct_below_good
FROM network_measurements
GROUP BY environment
ORDER BY mean_signal_dbm DESC;  -- Best signal first


-- =============================================================
-- QUERY 02: Signal Quality by Call Type
-- =============================================================
SELECT
    call_type,
    COUNT(*)                                                AS total_records,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm,
    ROUND(MIN(signal_strength_dbm), 2)                     AS min_signal_dbm,
    ROUND(MAX(signal_strength_dbm), 2)                     AS max_signal_dbm,
    SUM(CASE WHEN signal_quality_category = 'Excellent' THEN 1 ELSE 0 END) AS cnt_excellent,
    SUM(CASE WHEN signal_quality_category = 'Good'      THEN 1 ELSE 0 END) AS cnt_good,
    SUM(CASE WHEN signal_quality_category = 'Fair'      THEN 1 ELSE 0 END) AS cnt_fair,
    SUM(CASE WHEN signal_quality_category = 'Poor'      THEN 1 ELSE 0 END) AS cnt_poor,
    ROUND(SUM(CASE WHEN signal_quality_category IN ('Fair','Poor') THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 2)                             AS pct_below_good
FROM network_measurements
GROUP BY call_type
ORDER BY call_type;


-- =============================================================
-- QUERY 03: Signal Quality by Direction
-- =============================================================
SELECT
    direction,
    COUNT(*)                                                AS total_records,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm,
    SUM(CASE WHEN signal_quality_category IN ('Fair','Poor') THEN 1 ELSE 0 END) AS cnt_below_good,
    ROUND(SUM(CASE WHEN signal_quality_category IN ('Fair','Poor') THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 2)                             AS pct_below_good
FROM network_measurements
GROUP BY direction;


-- =============================================================
-- QUERY 04: Signal Quality per Tower — Full Breakdown
-- =============================================================
SELECT
    tower_id,
    COUNT(*)                                                AS total_records,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm,
    ROUND(MIN(signal_strength_dbm), 2)                     AS min_signal_dbm,
    ROUND(MAX(signal_strength_dbm), 2)                     AS max_signal_dbm,
    ROUND(STDDEV_SAMP(signal_strength_dbm), 2)             AS stddev_signal,
    SUM(CASE WHEN signal_quality_category = 'Excellent' THEN 1 ELSE 0 END) AS cnt_excellent,
    SUM(CASE WHEN signal_quality_category = 'Good'      THEN 1 ELSE 0 END) AS cnt_good,
    SUM(CASE WHEN signal_quality_category = 'Fair'      THEN 1 ELSE 0 END) AS cnt_fair,
    SUM(CASE WHEN signal_quality_category = 'Poor'      THEN 1 ELSE 0 END) AS cnt_poor,
    ROUND(SUM(CASE WHEN signal_quality_category IN ('Fair','Poor') THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 2)                             AS pct_below_good,
    -- Tower performance rank
    RANK() OVER (ORDER BY AVG(signal_strength_dbm) DESC)   AS signal_rank_best_to_worst
FROM network_measurements
GROUP BY tower_id
ORDER BY mean_signal_dbm DESC;


-- =============================================================
-- QUERY 05: Top 10 Worst Signal Measurements
-- =============================================================
SELECT
    id,
    timestamp,
    signal_strength_dbm,
    signal_quality_category,
    snr,
    attenuation,
    distance_to_tower_km,
    tower_id,
    user_id,
    environment,
    call_type,
    problem_score
FROM network_measurements
ORDER BY signal_strength_dbm ASC
LIMIT 10;


-- =============================================================
-- QUERY 06: Top 10 Best Signal Measurements
-- =============================================================
SELECT
    id,
    timestamp,
    signal_strength_dbm,
    signal_quality_category,
    snr,
    attenuation,
    distance_to_tower_km,
    tower_id,
    user_id,
    environment,
    call_type,
    problem_score
FROM network_measurements
ORDER BY signal_strength_dbm DESC
LIMIT 10;


-- =============================================================
-- QUERY 07: Signal Distribution Buckets (histogram bins)
-- =============================================================
SELECT
    CASE
        WHEN signal_strength_dbm >= -55  THEN '[-55, 0]   Exceptional'
        WHEN signal_strength_dbm >= -65  THEN '[-65, -55] Very Good'
        WHEN signal_strength_dbm >= -75  THEN '[-75, -65] Good'
        WHEN signal_strength_dbm >= -85  THEN '[-85, -75] Acceptable'
        WHEN signal_strength_dbm >= -95  THEN '[-95, -85] Fair'
        WHEN signal_strength_dbm >= -105 THEN '[-105,-95] Weak'
        WHEN signal_strength_dbm >= -115 THEN '[-115,-105] Very Weak'
        ELSE                                  '< -115     Critical'
    END                                                     AS signal_bucket,
    COUNT(*)                                                AS record_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM network_measurements) * 100, 2) AS pct
FROM network_measurements
GROUP BY signal_bucket
ORDER BY MIN(signal_strength_dbm) DESC;


-- =============================================================
-- QUERY 08: Signal Quality — Cross Tabulation (Environment x Category)
-- =============================================================
SELECT
    environment,
    SUM(CASE WHEN signal_quality_category = 'Excellent' THEN 1 ELSE 0 END) AS Excellent,
    SUM(CASE WHEN signal_quality_category = 'Good'      THEN 1 ELSE 0 END) AS Good,
    SUM(CASE WHEN signal_quality_category = 'Fair'      THEN 1 ELSE 0 END) AS Fair,
    SUM(CASE WHEN signal_quality_category = 'Poor'      THEN 1 ELSE 0 END) AS Poor,
    COUNT(*)                                                AS Total
FROM network_measurements
GROUP BY environment
ORDER BY FIELD(environment, 'home','open','suburban','urban');


-- =============================================================
-- QUERY 09: Signal with Running Average (Window Function)
-- =============================================================
WITH ordered_signal AS (
    SELECT
        id,
        timestamp,
        signal_strength_dbm,
        signal_quality_category,
        environment,
        tower_id,
        AVG(signal_strength_dbm) OVER (
            ORDER BY timestamp
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        )                                                   AS rolling_5_avg_signal,
        ROW_NUMBER() OVER (ORDER BY timestamp)              AS row_seq
    FROM network_measurements
    WHERE timestamp IS NOT NULL
)
SELECT
    id,
    timestamp,
    signal_strength_dbm,
    signal_quality_category,
    ROUND(rolling_5_avg_signal, 2)                         AS rolling_5_avg_signal,
    tower_id,
    environment
FROM ordered_signal
ORDER BY timestamp;


-- =============================================================
-- QUERY 10: Signal Percentile Ranking per Record
-- =============================================================
SELECT
    id,
    signal_strength_dbm,
    signal_quality_category,
    tower_id,
    environment,
    ROUND(PERCENT_RANK() OVER (ORDER BY signal_strength_dbm DESC) * 100, 1) AS pct_rank_weakest,
    DENSE_RANK() OVER (ORDER BY signal_strength_dbm ASC)    AS rank_weakest
FROM network_measurements
ORDER BY signal_strength_dbm ASC
LIMIT 20;


-- =============================================================
-- QUERY 11: Monthly Signal Trend
-- =============================================================
SELECT
    month_val,
    CASE month_val
        WHEN 1 THEN 'Jan' WHEN 2 THEN 'Feb'  WHEN 3 THEN 'Mar'
        WHEN 4 THEN 'Apr' WHEN 5 THEN 'May'  WHEN 6 THEN 'Jun'
        WHEN 7 THEN 'Jul' WHEN 8 THEN 'Aug'  WHEN 9 THEN 'Sep'
        WHEN 10 THEN 'Oct' WHEN 11 THEN 'Nov' WHEN 12 THEN 'Dec'
    END                                                     AS month_abbr,
    COUNT(*)                                                AS record_count,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm,
    ROUND(MIN(signal_strength_dbm), 2)                     AS min_signal_dbm,
    ROUND(MAX(signal_strength_dbm), 2)                     AS max_signal_dbm,
    SUM(CASE WHEN signal_quality_category = 'Poor' THEN 1 ELSE 0 END) AS cnt_poor,
    ROUND(SUM(CASE WHEN signal_quality_category = 'Poor' THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 2)                             AS pct_poor
FROM network_measurements
WHERE month_val IS NOT NULL
GROUP BY month_val
ORDER BY month_val;
