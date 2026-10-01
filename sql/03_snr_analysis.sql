-- =============================================================
-- 03_snr_analysis.sql
-- Project  : Telecom Network Quality Intelligence
-- Purpose  : SNR and call duration analysis
-- Date     : 2026-09-27
-- =============================================================

USE telecom_nqi;

-- =============================================================
-- QUERY 01: SNR Category Distribution
-- =============================================================
SELECT
    snr_category,
    COUNT(*)                                                AS record_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM network_measurements) * 100, 2) AS pct,
    ROUND(MIN(snr), 4)                                     AS min_snr,
    ROUND(MAX(snr), 4)                                     AS max_snr,
    ROUND(AVG(snr), 4)                                     AS mean_snr,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm
FROM network_measurements
GROUP BY snr_category
ORDER BY FIELD(snr_category, 'High','Moderate','Low');


-- =============================================================
-- QUERY 02: SNR by Environment
-- =============================================================
SELECT
    environment,
    COUNT(*)                                                AS record_count,
    ROUND(AVG(snr), 4)                                     AS mean_snr,
    ROUND(MIN(snr), 4)                                     AS min_snr,
    ROUND(MAX(snr), 4)                                     AS max_snr,
    ROUND(STDDEV_SAMP(snr), 4)                             AS stddev_snr,
    SUM(CASE WHEN snr_category = 'High'     THEN 1 ELSE 0 END) AS cnt_high_snr,
    SUM(CASE WHEN snr_category = 'Moderate' THEN 1 ELSE 0 END) AS cnt_moderate_snr,
    SUM(CASE WHEN snr_category = 'Low'      THEN 1 ELSE 0 END) AS cnt_low_snr,
    ROUND(SUM(CASE WHEN snr_category = 'Low' THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 2)                             AS pct_low_snr
FROM network_measurements
GROUP BY environment
ORDER BY mean_snr DESC;


-- =============================================================
-- QUERY 03: SNR by Tower
-- =============================================================
SELECT
    tower_id,
    COUNT(*)                                                AS record_count,
    ROUND(AVG(snr), 4)                                     AS mean_snr,
    ROUND(MIN(snr), 4)                                     AS min_snr,
    ROUND(MAX(snr), 4)                                     AS max_snr,
    SUM(CASE WHEN snr_category = 'Low' THEN 1 ELSE 0 END)  AS cnt_low_snr,
    ROUND(SUM(CASE WHEN snr_category = 'Low' THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 2)                             AS pct_low_snr,
    RANK() OVER (ORDER BY AVG(snr) DESC)                   AS snr_rank
FROM network_measurements
GROUP BY tower_id
ORDER BY mean_snr DESC;


-- =============================================================
-- QUERY 04: SNR vs Signal Strength — Correlation Check
-- =============================================================
-- Pearson correlation approximation via SQL
SELECT
    COUNT(*)                                                AS n,
    ROUND(
        (COUNT(*) * SUM(snr * signal_strength_dbm) - SUM(snr) * SUM(signal_strength_dbm))
        /
        SQRT(
            (COUNT(*) * SUM(snr * snr) - SUM(snr) * SUM(snr)) *
            (COUNT(*) * SUM(signal_strength_dbm * signal_strength_dbm) -
             SUM(signal_strength_dbm) * SUM(signal_strength_dbm))
        )
    , 4)                                                    AS pearson_r_snr_vs_signal
FROM network_measurements;


-- =============================================================
-- QUERY 05: SNR Category Cross-Tab with Signal Quality
-- =============================================================
SELECT
    snr_category,
    SUM(CASE WHEN signal_quality_category = 'Excellent' THEN 1 ELSE 0 END) AS sig_excellent,
    SUM(CASE WHEN signal_quality_category = 'Good'      THEN 1 ELSE 0 END) AS sig_good,
    SUM(CASE WHEN signal_quality_category = 'Fair'      THEN 1 ELSE 0 END) AS sig_fair,
    SUM(CASE WHEN signal_quality_category = 'Poor'      THEN 1 ELSE 0 END) AS sig_poor,
    COUNT(*)                                                AS total
FROM network_measurements
GROUP BY snr_category
ORDER BY FIELD(snr_category, 'High','Moderate','Low');


-- =============================================================
-- QUERY 06: Call Duration Analysis by Signal Quality
-- =============================================================
SELECT
    signal_quality_category,
    COUNT(*)                                                AS record_count,
    ROUND(AVG(call_duration_s), 2)                         AS mean_duration_s,
    ROUND(MIN(call_duration_s), 2)                         AS min_duration_s,
    ROUND(MAX(call_duration_s), 2)                         AS max_duration_s,
    ROUND(STDDEV_SAMP(call_duration_s), 2)                 AS stddev_duration_s
FROM network_measurements
GROUP BY signal_quality_category
ORDER BY FIELD(signal_quality_category, 'Excellent','Good','Fair','Poor');


-- =============================================================
-- QUERY 07: Call Duration by Call Type
-- =============================================================
SELECT
    call_type,
    COUNT(*)                                                AS record_count,
    ROUND(AVG(call_duration_s), 2)                         AS mean_duration_s,
    ROUND(MIN(call_duration_s), 2)                         AS min_duration_s,
    ROUND(MAX(call_duration_s), 2)                         AS max_duration_s,
    ROUND(AVG(snr), 4)                                     AS mean_snr,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm
FROM network_measurements
GROUP BY call_type
ORDER BY call_type;


-- =============================================================
-- QUERY 08: SNR Percentile Ranking per Record
-- =============================================================
SELECT
    id,
    snr,
    snr_category,
    signal_strength_dbm,
    signal_quality_category,
    tower_id,
    environment,
    DENSE_RANK() OVER (ORDER BY snr ASC)                   AS snr_rank_low_to_high,
    ROUND(PERCENT_RANK() OVER (ORDER BY snr ASC) * 100, 1) AS snr_percentile
FROM network_measurements
ORDER BY snr ASC
LIMIT 20;


-- =============================================================
-- QUERY 09: Top 10 Records with Lowest SNR
-- =============================================================
SELECT
    id,
    timestamp,
    snr,
    snr_category,
    signal_strength_dbm,
    signal_quality_category,
    attenuation,
    distance_to_tower_km,
    tower_id,
    user_id,
    environment,
    call_type,
    problem_score
FROM network_measurements
ORDER BY snr ASC
LIMIT 10;


-- =============================================================
-- QUERY 10: Monthly SNR Trend
-- =============================================================
SELECT
    month_val,
    CASE month_val
        WHEN 1 THEN 'Jan' WHEN 2 THEN 'Feb'  WHEN 3 THEN 'Mar'
        WHEN 4 THEN 'Apr' WHEN 5 THEN 'May'  WHEN 6 THEN 'Jun'
        WHEN 7 THEN 'Jul' WHEN 8 THEN 'Aug'  WHEN 9 THEN 'Sep'
        WHEN 10 THEN 'Oct' WHEN 11 THEN 'Nov' WHEN 12 THEN 'Dec'
    END                                                     AS month_name,
    COUNT(*)                                                AS record_count,
    ROUND(AVG(snr), 4)                                     AS mean_snr,
    ROUND(AVG(call_duration_s), 2)                         AS mean_call_duration_s
FROM network_measurements
WHERE month_val IS NOT NULL
GROUP BY month_val
ORDER BY month_val;
