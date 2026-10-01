-- =============================================================
-- 06_problem_prioritization.sql
-- Project  : Telecom Network Quality Intelligence
-- Purpose  : Problem identification, scoring, and investigation
--            priority ranking
-- Date     : 2026-09-27
-- =============================================================

USE telecom_nqi;

-- =============================================================
-- QUERY 01: Problem Score Overview
-- =============================================================
SELECT
    problem_score,
    is_problematic,
    COUNT(*)                                                AS record_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM network_measurements) * 100, 2) AS pct,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm,
    ROUND(AVG(snr), 4)                                     AS mean_snr,
    ROUND(AVG(attenuation), 4)                             AS mean_attenuation,
    ROUND(AVG(distance_to_tower_km), 4)                    AS mean_distance_km
FROM network_measurements
GROUP BY problem_score, is_problematic
ORDER BY problem_score;


-- =============================================================
-- QUERY 02: Critical Records — Maximum Problem Score (4/4)
-- =============================================================
SELECT
    id,
    timestamp,
    signal_strength_dbm,
    signal_quality_category,
    snr,
    snr_category,
    attenuation,
    attenuation_category,
    distance_to_tower_km,
    distance_category,
    tower_id,
    user_id,
    environment,
    call_type,
    direction,
    problem_score,
    -- Flags to show which conditions triggered
    CASE WHEN signal_quality_category IN ('Fair','Poor') THEN 'YES' ELSE 'no' END AS condition_signal,
    CASE WHEN snr_category = 'Low'                       THEN 'YES' ELSE 'no' END AS condition_snr,
    CASE WHEN attenuation_category = 'High'              THEN 'YES' ELSE 'no' END AS condition_attenuation,
    CASE WHEN distance_category = 'Far'                  THEN 'YES' ELSE 'no' END AS condition_distance
FROM network_measurements
WHERE problem_score = 4
ORDER BY signal_strength_dbm ASC;


-- =============================================================
-- QUERY 03: All Problematic Records (Score >= 2)
--           Ranked by severity (problem_score DESC, signal ASC)
-- =============================================================
WITH problematic_ranked AS (
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
        problem_score,
        ROW_NUMBER() OVER (
            ORDER BY problem_score DESC, signal_strength_dbm ASC
        )                                                   AS priority_rank
    FROM network_measurements
    WHERE is_problematic = 1
)
SELECT
    priority_rank,
    id,
    timestamp,
    ROUND(signal_strength_dbm, 2)                          AS signal_strength_dbm,
    signal_quality_category,
    ROUND(snr, 4)                                          AS snr,
    ROUND(attenuation, 4)                                  AS attenuation,
    ROUND(distance_to_tower_km, 4)                         AS distance_to_tower_km,
    tower_id,
    user_id,
    environment,
    call_type,
    problem_score
FROM problematic_ranked
ORDER BY priority_rank;


-- =============================================================
-- QUERY 04: Tower Problem Scorecard
-- =============================================================
SELECT
    tower_id,
    COUNT(*)                                                AS total_records,
    SUM(is_problematic)                                     AS problematic_records,
    ROUND(SUM(is_problematic) / COUNT(*) * 100, 2)         AS pct_problematic,
    ROUND(AVG(problem_score), 3)                           AS avg_problem_score,
    SUM(CASE WHEN problem_score = 4 THEN 1 ELSE 0 END)     AS cnt_critical_score_4,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm,
    ROUND(AVG(snr), 4)                                     AS mean_snr,
    -- Combined tower health rank (lower rank = more problematic)
    RANK() OVER (ORDER BY
        SUM(is_problematic) / COUNT(*) DESC,
        AVG(signal_strength_dbm) ASC
    )                                                       AS problem_rank
FROM network_measurements
GROUP BY tower_id
ORDER BY problem_rank;


-- =============================================================
-- QUERY 05: Environment Problem Analysis
-- =============================================================
SELECT
    environment,
    COUNT(*)                                                AS total_records,
    SUM(is_problematic)                                     AS problematic_records,
    ROUND(SUM(is_problematic) / COUNT(*) * 100, 2)         AS pct_problematic,
    ROUND(AVG(problem_score), 3)                           AS avg_problem_score,
    SUM(CASE WHEN problem_score = 4 THEN 1 ELSE 0 END)     AS cnt_critical,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal_dbm
FROM network_measurements
GROUP BY environment
ORDER BY pct_problematic DESC;


-- =============================================================
-- QUERY 06: User Problem Analysis — Top 20 Most-Affected Users
-- =============================================================
WITH user_summary AS (
    SELECT
        user_id,
        COUNT(*)                                            AS total_sessions,
        SUM(is_problematic)                                 AS problematic_sessions,
        ROUND(SUM(is_problematic) / COUNT(*) * 100, 2)     AS pct_problematic,
        ROUND(AVG(signal_strength_dbm), 2)                 AS mean_signal_dbm,
        ROUND(AVG(problem_score), 3)                       AS avg_problem_score,
        MIN(signal_strength_dbm)                           AS worst_signal,
        RANK() OVER (ORDER BY SUM(is_problematic) DESC,
                              AVG(signal_strength_dbm) ASC) AS user_priority_rank
    FROM network_measurements
    GROUP BY user_id
)
SELECT
    user_priority_rank,
    user_id,
    total_sessions,
    problematic_sessions,
    pct_problematic,
    mean_signal_dbm,
    avg_problem_score,
    ROUND(worst_signal, 2)                                 AS worst_signal_dbm
FROM user_summary
WHERE problematic_sessions > 0
ORDER BY user_priority_rank
LIMIT 20;


-- =============================================================
-- QUERY 07: Condition Breakdown — How Often Each Condition Fires
-- =============================================================
SELECT
    'Bad Signal (Fair or Poor)'                             AS condition_name,
    SUM(CASE WHEN signal_quality_category IN ('Fair','Poor') THEN 1 ELSE 0 END) AS triggered_count,
    ROUND(SUM(CASE WHEN signal_quality_category IN ('Fair','Poor') THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 2)                             AS triggered_pct
FROM network_measurements
UNION ALL
SELECT
    'Low SNR',
    SUM(CASE WHEN snr_category = 'Low' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN snr_category = 'Low' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2)
FROM network_measurements
UNION ALL
SELECT
    'High Attenuation',
    SUM(CASE WHEN attenuation_category = 'High' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN attenuation_category = 'High' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2)
FROM network_measurements
UNION ALL
SELECT
    'Far Distance',
    SUM(CASE WHEN distance_category = 'Far' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN distance_category = 'Far' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2)
FROM network_measurements;


-- =============================================================
-- QUERY 08: Problem Pattern — Condition Combinations
-- =============================================================
SELECT
    CASE WHEN signal_quality_category IN ('Fair','Poor') THEN 1 ELSE 0 END AS bad_signal,
    CASE WHEN snr_category = 'Low'                       THEN 1 ELSE 0 END AS low_snr,
    CASE WHEN attenuation_category = 'High'              THEN 1 ELSE 0 END AS high_att,
    CASE WHEN distance_category = 'Far'                  THEN 1 ELSE 0 END AS far_dist,
    COUNT(*)                                                AS occurrences,
    ROUND(AVG(signal_strength_dbm), 2)                     AS mean_signal
FROM network_measurements
GROUP BY bad_signal, low_snr, high_att, far_dist
ORDER BY occurrences DESC;


-- =============================================================
-- QUERY 09: Problematic Records — Monthly Distribution
-- =============================================================
SELECT
    month_val,
    CASE month_val
        WHEN 1 THEN 'Jan' WHEN 2 THEN 'Feb'  WHEN 3 THEN 'Mar'
        WHEN 4 THEN 'Apr' WHEN 5 THEN 'May'  WHEN 6 THEN 'Jun'
        WHEN 7 THEN 'Jul' WHEN 8 THEN 'Aug'  WHEN 9 THEN 'Sep'
        WHEN 10 THEN 'Oct' WHEN 11 THEN 'Nov' WHEN 12 THEN 'Dec'
    END                                                     AS month_name,
    COUNT(*)                                                AS total_records,
    SUM(is_problematic)                                     AS problematic_records,
    ROUND(SUM(is_problematic) / COUNT(*) * 100, 2)         AS pct_problematic
FROM network_measurements
WHERE month_val IS NOT NULL
GROUP BY month_val
ORDER BY month_val;


-- =============================================================
-- QUERY 10: Full Investigation Priority List (ALL problematic)
-- =============================================================
-- This is the master investigation list for engineering teams.
-- Sorted by: problem_score DESC, signal_strength ASC (worst first)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY problem_score DESC, signal_strength_dbm ASC
    )                                                       AS investigation_priority,
    id                                                      AS record_id,
    timestamp,
    ROUND(signal_strength_dbm, 2)                          AS signal_dbm,
    signal_quality_category                                AS signal_quality,
    ROUND(snr, 2)                                          AS snr_db,
    snr_category,
    ROUND(attenuation, 4)                                  AS attenuation,
    attenuation_category,
    ROUND(distance_to_tower_km, 2)                         AS distance_km,
    distance_category,
    tower_id,
    user_id,
    environment,
    call_type,
    direction,
    problem_score,
    CASE
        WHEN problem_score = 4 THEN 'CRITICAL'
        WHEN problem_score = 3 THEN 'HIGH'
        WHEN problem_score = 2 THEN 'MEDIUM'
        ELSE                        'LOW'
    END                                                     AS priority_level
FROM network_measurements
WHERE is_problematic = 1
ORDER BY investigation_priority;
