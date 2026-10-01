-- =============================================================
-- 04_attenuation_analysis.sql
-- Project  : Telecom Network Quality Intelligence
-- Purpose  : Attenuation analysis
-- Date     : 2026-09-27
-- =============================================================

USE telecom_nqi;

-- =============================================================
-- QUERY 01: Attenuation Category Distribution
-- =============================================================
SELECT
    attenuation_category,
    COUNT(*)                                                AS record_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM network_measurements) * 100, 2) AS pct,
    ROUND(MIN(attenuation), 4)                             AS min_attenuation,
    ROUND(MAX(attenuation), 4)                             AS max_attenuation,
    ROUND(AVG(attenuation), 4)                             AS mean_attenuation,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm
FROM network_measurements
GROUP BY attenuation_category
ORDER BY FIELD(attenuation_category, 'Low','Medium','High');


-- =============================================================
-- QUERY 02: Attenuation by Environment
-- =============================================================
SELECT
    environment,
    COUNT(*)                                                AS record_count,
    ROUND(AVG(attenuation), 4)                             AS mean_attenuation,
    ROUND(MIN(attenuation), 4)                             AS min_attenuation,
    ROUND(MAX(attenuation), 4)                             AS max_attenuation,
    ROUND(STDDEV_SAMP(attenuation), 4)                     AS stddev_attenuation,
    SUM(CASE WHEN attenuation_outlier_flag = 1 THEN 1 ELSE 0 END) AS iqr_outliers,
    ROUND(SUM(CASE WHEN attenuation_category = 'High' THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 2)                             AS pct_high_attenuation
FROM network_measurements
GROUP BY environment
ORDER BY mean_attenuation DESC;


-- =============================================================
-- QUERY 03: Attenuation Outliers Detail
-- =============================================================
SELECT
    id,
    timestamp,
    attenuation,
    signal_strength_dbm,
    signal_quality_category,
    snr,
    distance_to_tower_km,
    tower_id,
    user_id,
    environment,
    call_type,
    problem_score,
    attenuation_outlier_flag
FROM network_measurements
WHERE attenuation_outlier_flag = 1
ORDER BY attenuation DESC;


-- =============================================================
-- QUERY 04: Attenuation vs Signal Strength — Correlation
-- =============================================================
SELECT
    COUNT(*)                                                AS n,
    ROUND(
        (COUNT(*) * SUM(attenuation * signal_strength_dbm) -
         SUM(attenuation) * SUM(signal_strength_dbm))
        /
        SQRT(
            (COUNT(*) * SUM(attenuation * attenuation) -
             SUM(attenuation) * SUM(attenuation)) *
            (COUNT(*) * SUM(signal_strength_dbm * signal_strength_dbm) -
             SUM(signal_strength_dbm) * SUM(signal_strength_dbm))
        )
    , 4)                                                    AS pearson_r_att_vs_signal
FROM network_measurements;


-- =============================================================
-- QUERY 05: Attenuation vs Distance — Correlation
-- =============================================================
SELECT
    COUNT(*)                                                AS n,
    ROUND(
        (COUNT(*) * SUM(attenuation * distance_to_tower_km) -
         SUM(attenuation) * SUM(distance_to_tower_km))
        /
        SQRT(
            (COUNT(*) * SUM(attenuation * attenuation) -
             SUM(attenuation) * SUM(attenuation)) *
            (COUNT(*) * SUM(distance_to_tower_km * distance_to_tower_km) -
             SUM(distance_to_tower_km) * SUM(distance_to_tower_km))
        )
    , 4)                                                    AS pearson_r_att_vs_distance
FROM network_measurements;


-- =============================================================
-- QUERY 06: Attenuation Category vs Signal Quality Cross-Tab
-- =============================================================
SELECT
    attenuation_category,
    SUM(CASE WHEN signal_quality_category = 'Excellent' THEN 1 ELSE 0 END) AS sig_excellent,
    SUM(CASE WHEN signal_quality_category = 'Good'      THEN 1 ELSE 0 END) AS sig_good,
    SUM(CASE WHEN signal_quality_category = 'Fair'      THEN 1 ELSE 0 END) AS sig_fair,
    SUM(CASE WHEN signal_quality_category = 'Poor'      THEN 1 ELSE 0 END) AS sig_poor,
    COUNT(*)                                                AS total,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm
FROM network_measurements
GROUP BY attenuation_category
ORDER BY FIELD(attenuation_category, 'Low','Medium','High');


-- =============================================================
-- QUERY 07: Attenuation by Tower
-- =============================================================
SELECT
    tower_id,
    COUNT(*)                                                AS record_count,
    ROUND(AVG(attenuation), 4)                             AS mean_attenuation,
    ROUND(MAX(attenuation), 4)                             AS max_attenuation,
    SUM(CASE WHEN attenuation_category = 'High' THEN 1 ELSE 0 END) AS cnt_high_att,
    SUM(CASE WHEN attenuation_outlier_flag = 1  THEN 1 ELSE 0 END) AS iqr_outliers,
    RANK() OVER (ORDER BY AVG(attenuation) DESC)           AS att_rank_high_to_low
FROM network_measurements
GROUP BY tower_id
ORDER BY mean_attenuation DESC;


-- =============================================================
-- QUERY 08: Attenuation Decile Distribution
-- =============================================================
WITH att_deciles AS (
    SELECT
        attenuation,
        NTILE(10) OVER (ORDER BY attenuation) AS decile
    FROM network_measurements
)
SELECT
    decile,
    COUNT(*)                                                AS record_count,
    ROUND(MIN(attenuation), 4)                             AS decile_min,
    ROUND(MAX(attenuation), 4)                             AS decile_max,
    ROUND(AVG(attenuation), 4)                             AS decile_mean
FROM att_deciles
GROUP BY decile
ORDER BY decile;
