-- =============================================================
-- 05_distance_analysis.sql
-- Project  : Telecom Network Quality Intelligence
-- Purpose  : Distance to tower analysis
-- Date     : 2026-09-27
-- =============================================================

USE telecom_nqi;

-- =============================================================
-- QUERY 01: Distance Category Distribution
-- =============================================================
SELECT
    distance_category,
    COUNT(*)                                                AS record_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM network_measurements) * 100, 2) AS pct,
    ROUND(MIN(distance_to_tower_km), 4)                    AS min_distance_km,
    ROUND(MAX(distance_to_tower_km), 4)                    AS max_distance_km,
    ROUND(AVG(distance_to_tower_km), 4)                    AS mean_distance_km,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm,
    ROUND(AVG(snr), 4)                                     AS mean_snr
FROM network_measurements
GROUP BY distance_category
ORDER BY FIELD(distance_category, 'Near','Mid','Far');


-- =============================================================
-- QUERY 02: Signal Quality by Distance Category
-- =============================================================
SELECT
    distance_category,
    COUNT(*)                                                AS total_records,
    SUM(CASE WHEN signal_quality_category = 'Excellent' THEN 1 ELSE 0 END) AS cnt_excellent,
    SUM(CASE WHEN signal_quality_category = 'Good'      THEN 1 ELSE 0 END) AS cnt_good,
    SUM(CASE WHEN signal_quality_category = 'Fair'      THEN 1 ELSE 0 END) AS cnt_fair,
    SUM(CASE WHEN signal_quality_category = 'Poor'      THEN 1 ELSE 0 END) AS cnt_poor,
    ROUND(SUM(CASE WHEN signal_quality_category IN ('Fair','Poor') THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 2)                             AS pct_poor_or_fair,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm
FROM network_measurements
GROUP BY distance_category
ORDER BY FIELD(distance_category, 'Near','Mid','Far');


-- =============================================================
-- QUERY 03: Distance vs Signal Strength — Correlation
-- =============================================================
SELECT
    COUNT(*)                                                AS n,
    ROUND(
        (COUNT(*) * SUM(distance_to_tower_km * signal_strength_dbm) -
         SUM(distance_to_tower_km) * SUM(signal_strength_dbm))
        /
        SQRT(
            (COUNT(*) * SUM(distance_to_tower_km * distance_to_tower_km) -
             SUM(distance_to_tower_km) * SUM(distance_to_tower_km)) *
            (COUNT(*) * SUM(signal_strength_dbm * signal_strength_dbm) -
             SUM(signal_strength_dbm) * SUM(signal_strength_dbm))
        )
    , 4)                                                    AS pearson_r_distance_vs_signal,
    ROUND(
        (COUNT(*) * SUM(distance_to_tower_km * snr) -
         SUM(distance_to_tower_km) * SUM(snr))
        /
        SQRT(
            (COUNT(*) * SUM(distance_to_tower_km * distance_to_tower_km) -
             SUM(distance_to_tower_km) * SUM(distance_to_tower_km)) *
            (COUNT(*) * SUM(snr * snr) - SUM(snr) * SUM(snr))
        )
    , 4)                                                    AS pearson_r_distance_vs_snr
FROM network_measurements;


-- =============================================================
-- QUERY 04: Distance by Environment
-- =============================================================
SELECT
    environment,
    COUNT(*)                                                AS record_count,
    ROUND(AVG(distance_to_tower_km), 4)                    AS mean_distance_km,
    ROUND(MIN(distance_to_tower_km), 4)                    AS min_distance_km,
    ROUND(MAX(distance_to_tower_km), 4)                    AS max_distance_km,
    SUM(CASE WHEN distance_category = 'Near' THEN 1 ELSE 0 END) AS cnt_near,
    SUM(CASE WHEN distance_category = 'Mid'  THEN 1 ELSE 0 END) AS cnt_mid,
    SUM(CASE WHEN distance_category = 'Far'  THEN 1 ELSE 0 END) AS cnt_far
FROM network_measurements
GROUP BY environment
ORDER BY mean_distance_km;


-- =============================================================
-- QUERY 05: Distance by Tower
-- =============================================================
SELECT
    tower_id,
    COUNT(*)                                                AS record_count,
    ROUND(AVG(distance_to_tower_km), 4)                    AS mean_distance_km,
    ROUND(MIN(distance_to_tower_km), 4)                    AS min_distance_km,
    ROUND(MAX(distance_to_tower_km), 4)                    AS max_distance_km,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm
FROM network_measurements
GROUP BY tower_id
ORDER BY mean_distance_km;


-- =============================================================
-- QUERY 06: Distance Bands — Signal Quality breakdown
-- =============================================================
SELECT
    CASE
        WHEN distance_to_tower_km < 2  THEN '0-2 km'
        WHEN distance_to_tower_km < 4  THEN '2-4 km'
        WHEN distance_to_tower_km < 6  THEN '4-6 km'
        WHEN distance_to_tower_km < 8  THEN '6-8 km'
        ELSE                                '8-10 km'
    END                                                     AS distance_band,
    COUNT(*)                                                AS record_count,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm,
    ROUND(AVG(snr), 4)                                     AS mean_snr,
    ROUND(AVG(attenuation), 4)                             AS mean_attenuation,
    SUM(CASE WHEN signal_quality_category IN ('Fair','Poor') THEN 1 ELSE 0 END) AS cnt_below_good,
    ROUND(SUM(CASE WHEN signal_quality_category IN ('Fair','Poor') THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 2)                             AS pct_below_good
FROM network_measurements
GROUP BY distance_band
ORDER BY MIN(distance_to_tower_km);


-- =============================================================
-- QUERY 07: Distance Percentile Analysis
-- =============================================================
WITH dist_ranked AS (
    SELECT
        id,
        distance_to_tower_km,
        signal_strength_dbm,
        signal_quality_category,
        environment,
        tower_id,
        NTILE(4) OVER (ORDER BY distance_to_tower_km) AS distance_quartile
    FROM network_measurements
)
SELECT
    distance_quartile,
    COUNT(*)                                                AS record_count,
    ROUND(MIN(distance_to_tower_km), 4)                    AS q_min_km,
    ROUND(MAX(distance_to_tower_km), 4)                    AS q_max_km,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm,
    SUM(CASE WHEN signal_quality_category IN ('Fair','Poor') THEN 1 ELSE 0 END) AS cnt_poor_fair
FROM dist_ranked
GROUP BY distance_quartile
ORDER BY distance_quartile;
