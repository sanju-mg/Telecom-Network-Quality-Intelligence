-- =============================================================
-- 01_basic_analysis.sql
-- Project  : Telecom Network Quality Intelligence
-- Purpose  : Basic statistics and overview queries
-- Run on   : telecom_nqi.network_measurements
-- Date     : 2026-09-27
-- =============================================================

USE telecom_nqi;

-- =============================================================
-- QUERY 01: Dataset Overview
-- =============================================================
SELECT
    COUNT(*)                                                AS total_records,
    COUNT(DISTINCT tower_id)                                AS unique_towers,
    COUNT(DISTINCT user_id)                                 AS unique_users,
    COUNT(DISTINCT environment)                             AS unique_environments,
    COUNT(DISTINCT call_type)                               AS unique_call_types,
    COUNT(timestamp)                                        AS records_with_valid_timestamp,
    SUM(CASE WHEN timestamp IS NULL THEN 1 ELSE 0 END)      AS records_with_null_timestamp,
    MIN(timestamp)                                          AS earliest_timestamp,
    MAX(timestamp)                                          AS latest_timestamp,
    SUM(is_problematic)                                     AS total_problematic_records,
    ROUND(SUM(is_problematic) / COUNT(*) * 100, 2)          AS pct_problematic
FROM network_measurements;


-- =============================================================
-- QUERY 02: Signal Strength — Descriptive Statistics
-- =============================================================
SELECT
    ROUND(MIN(signal_strength_dbm), 4)                      AS min_signal,
    ROUND(MAX(signal_strength_dbm), 4)                      AS max_signal,
    ROUND(AVG(signal_strength_dbm), 4)                      AS mean_signal,
    ROUND(STDDEV_SAMP(signal_strength_dbm), 4)              AS stddev_signal,
    -- Median approximation using percentile approach
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP
        (ORDER BY signal_strength_dbm) OVER (), 4)          AS q1_signal,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
        (ORDER BY signal_strength_dbm) OVER (), 4)          AS median_signal,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP
        (ORDER BY signal_strength_dbm) OVER (), 4)          AS q3_signal
FROM network_measurements
LIMIT 1;

-- Alternative median (compatible with MySQL < 8.0.2):
SELECT
    ROUND(MIN(signal_strength_dbm), 4)       AS min_signal,
    ROUND(MAX(signal_strength_dbm), 4)       AS max_signal,
    ROUND(AVG(signal_strength_dbm), 4)       AS mean_signal,
    ROUND(STDDEV_SAMP(signal_strength_dbm), 4) AS stddev_signal,
    (   SELECT ROUND(AVG(signal_strength_dbm), 4)
        FROM (
            SELECT signal_strength_dbm,
                   ROW_NUMBER() OVER (ORDER BY signal_strength_dbm) AS rn,
                   COUNT(*) OVER ()                                  AS total
            FROM network_measurements
        ) t
        WHERE rn IN (FLOOR((total + 1) / 2), CEIL((total + 1) / 2))
    ) AS median_signal
FROM network_measurements;


-- =============================================================
-- QUERY 03: All Numeric KPIs — Summary Statistics
-- =============================================================
SELECT
    'signal_strength_dbm'   AS metric,
    ROUND(MIN(signal_strength_dbm), 4)       AS min_val,
    ROUND(MAX(signal_strength_dbm), 4)       AS max_val,
    ROUND(AVG(signal_strength_dbm), 4)       AS mean_val,
    ROUND(STDDEV_SAMP(signal_strength_dbm), 4) AS stddev_val
FROM network_measurements
UNION ALL
SELECT
    'snr'                   AS metric,
    ROUND(MIN(snr), 4), ROUND(MAX(snr), 4),
    ROUND(AVG(snr), 4), ROUND(STDDEV_SAMP(snr), 4)
FROM network_measurements
UNION ALL
SELECT
    'call_duration_s'       AS metric,
    ROUND(MIN(call_duration_s), 4), ROUND(MAX(call_duration_s), 4),
    ROUND(AVG(call_duration_s), 4), ROUND(STDDEV_SAMP(call_duration_s), 4)
FROM network_measurements
UNION ALL
SELECT
    'attenuation'           AS metric,
    ROUND(MIN(attenuation), 4), ROUND(MAX(attenuation), 4),
    ROUND(AVG(attenuation), 4), ROUND(STDDEV_SAMP(attenuation), 4)
FROM network_measurements
UNION ALL
SELECT
    'distance_to_tower_km'  AS metric,
    ROUND(MIN(distance_to_tower_km), 4), ROUND(MAX(distance_to_tower_km), 4),
    ROUND(AVG(distance_to_tower_km), 4), ROUND(STDDEV_SAMP(distance_to_tower_km), 4)
FROM network_measurements
ORDER BY metric;


-- =============================================================
-- QUERY 04: Categorical Column Distributions
-- =============================================================

-- Environment distribution
SELECT
    'environment'           AS column_name,
    environment             AS category,
    COUNT(*)                AS record_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM network_measurements) * 100, 2) AS pct
FROM network_measurements
GROUP BY environment
ORDER BY record_count DESC;

-- Call type distribution
SELECT
    'call_type'             AS column_name,
    call_type               AS category,
    COUNT(*)                AS record_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM network_measurements) * 100, 2) AS pct
FROM network_measurements
GROUP BY call_type
ORDER BY record_count DESC;

-- Direction distribution
SELECT
    'direction'             AS column_name,
    direction               AS category,
    COUNT(*)                AS record_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM network_measurements) * 100, 2) AS pct
FROM network_measurements
GROUP BY direction
ORDER BY record_count DESC;


-- =============================================================
-- QUERY 05: Signal Quality Category Summary
-- =============================================================
SELECT
    signal_quality_category,
    COUNT(*)                                                AS record_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM network_measurements) * 100, 2) AS pct,
    ROUND(MIN(signal_strength_dbm), 2)                     AS min_signal,
    ROUND(MAX(signal_strength_dbm), 2)                     AS max_signal,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal
FROM network_measurements
GROUP BY signal_quality_category
ORDER BY FIELD(signal_quality_category, 'Excellent','Good','Fair','Poor');


-- =============================================================
-- QUERY 06: Problem Score Distribution
-- =============================================================
SELECT
    problem_score,
    COUNT(*)                                                AS record_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM network_measurements) * 100, 2) AS pct,
    CASE WHEN problem_score >= 2 THEN 'Problematic' ELSE 'Clean' END AS classification,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal,
    ROUND(AVG(snr), 2)                                     AS mean_snr
FROM network_measurements
GROUP BY problem_score
ORDER BY problem_score;


-- =============================================================
-- QUERY 07: Records per Tower
-- =============================================================
SELECT
    tower_id,
    COUNT(*)                                                AS record_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM network_measurements) * 100, 2) AS pct,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal,
    ROUND(AVG(snr), 2)                                     AS mean_snr
FROM network_measurements
GROUP BY tower_id
ORDER BY tower_id;


-- =============================================================
-- QUERY 08: Monthly Record Count
-- =============================================================
SELECT
    month_val,
    CASE month_val
        WHEN 1 THEN 'January'   WHEN 2 THEN 'February' WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'     WHEN 5 THEN 'May'       WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'      WHEN 8 THEN 'August'    WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'  WHEN 11 THEN 'November' WHEN 12 THEN 'December'
    END                                                     AS month_name,
    COUNT(*)                                                AS record_count,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal,
    ROUND(AVG(snr), 2)                                     AS mean_snr
FROM network_measurements
WHERE month_val IS NOT NULL
GROUP BY month_val
ORDER BY month_val;


-- =============================================================
-- QUERY 09: Hourly Record Count and Mean Signal
-- =============================================================
SELECT
    hour_val,
    COUNT(*)                                                AS record_count,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal,
    ROUND(MIN(signal_strength_dbm), 2)                     AS min_signal,
    ROUND(MAX(signal_strength_dbm), 2)                     AS max_signal
FROM network_measurements
WHERE hour_val IS NOT NULL
GROUP BY hour_val
ORDER BY hour_val;


-- =============================================================
-- QUERY 10: Weekday vs Weekend Summary
-- =============================================================
SELECT
    CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    COUNT(*)                                                AS record_count,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal,
    ROUND(AVG(snr), 2)                                     AS mean_snr,
    ROUND(AVG(call_duration_s), 2)                         AS mean_call_duration_s
FROM network_measurements
WHERE is_weekend IS NOT NULL
GROUP BY is_weekend
ORDER BY is_weekend;
