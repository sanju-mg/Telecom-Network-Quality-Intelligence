-- =============================================================
-- schema.sql
-- Project  : Telecom Network Quality Intelligence
-- Dataset  : Kaggle Cellular Network Performance Data
-- Purpose  : MySQL schema for the cleaned dataset
-- Date     : 2026-09-27
-- =============================================================
-- USAGE:
--   mysql -u root -p < schema.sql
--   OR run in MySQL Workbench
-- =============================================================

-- Create and select database
CREATE DATABASE IF NOT EXISTS telecom_nqi
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE telecom_nqi;

-- Drop table if exists (for re-runs)
DROP TABLE IF EXISTS network_measurements;

-- =============================================================
-- MAIN TABLE: network_measurements
-- Source: data/cleaned/train_cleaned.csv
-- Rows  : 463
-- =============================================================
CREATE TABLE network_measurements (
    -- -------------------------------------------------------
    -- Primary key (row number from cleaned CSV)
    -- -------------------------------------------------------
    id                                INT UNSIGNED        NOT NULL AUTO_INCREMENT,

    -- -------------------------------------------------------
    -- ORIGINAL COLUMNS (from train.csv)
    -- -------------------------------------------------------
    timestamp                         DATETIME            NULL     COMMENT 'Measurement timestamp; NULL for row 422 (invalid date 2022-02-29)',
    signal_strength_dbm               DECIMAL(10,6)       NOT NULL COMMENT 'Received signal strength in dBm; closer to 0 = stronger; range [-118.68, -50.12]',
    snr                               DECIMAL(10,6)       NOT NULL COMMENT 'Signal-to-Noise Ratio in dB; higher = better; range [10.27, 29.96]',
    call_duration_s                   DECIMAL(12,6)       NOT NULL COMMENT 'Call or session duration in seconds; range [11.52, 1795.18]',
    environment                       VARCHAR(20)         NOT NULL COMMENT 'Environment type: urban | suburban | home | open',
    attenuation                       DECIMAL(10,6)       NOT NULL COMMENT 'Signal attenuation (unit unspecified); range [0.04, 14.94]',
    distance_to_tower_km              DECIMAL(10,6)       NOT NULL COMMENT 'Distance to nearest cell tower in km; range [0.03, 9.98]',
    tower_id                          TINYINT UNSIGNED    NOT NULL COMMENT 'Cell tower identifier; values 1-10',
    user_id                           SMALLINT UNSIGNED   NOT NULL COMMENT 'User identifier; values 1-100',
    call_type                         VARCHAR(10)         NOT NULL COMMENT 'Call type: data | voice',
    direction                         VARCHAR(10)         NOT NULL COMMENT 'Call direction: incoming | outgoing',

    -- -------------------------------------------------------
    -- OUTLIER FLAGS
    -- -------------------------------------------------------
    signal_strength_dbm_outlier_flag  TINYINT(1)          NOT NULL DEFAULT 0 COMMENT '1 = IQR outlier; 0 = normal (0 records flagged)',
    snr_outlier_flag                  TINYINT(1)          NOT NULL DEFAULT 0 COMMENT '1 = IQR outlier; 0 = normal (0 records flagged)',
    call_duration_s_outlier_flag      TINYINT(1)          NOT NULL DEFAULT 0 COMMENT '1 = IQR outlier; 0 = normal (0 records flagged)',
    attenuation_outlier_flag          TINYINT(1)          NOT NULL DEFAULT 0 COMMENT '1 = IQR outlier; 0 = normal (3 records flagged)',
    distance_to_tower_km_outlier_flag TINYINT(1)          NOT NULL DEFAULT 0 COMMENT '1 = IQR outlier; 0 = normal (0 records flagged)',

    -- -------------------------------------------------------
    -- DERIVED CATEGORY COLUMNS
    -- -------------------------------------------------------
    signal_quality_category           VARCHAR(15)         NOT NULL COMMENT 'Excellent | Good | Fair | Poor based on dBm thresholds',
    snr_category                      VARCHAR(10)         NOT NULL COMMENT 'High | Moderate | Low based on dataset quartiles',
    attenuation_category              VARCHAR(10)         NOT NULL COMMENT 'Low | Medium | High based on dataset quartiles',
    distance_category                 VARCHAR(10)         NOT NULL COMMENT 'Near | Mid | Far based on dataset quartiles',

    -- -------------------------------------------------------
    -- PROBLEM SCORING
    -- -------------------------------------------------------
    problem_score                     TINYINT UNSIGNED    NOT NULL COMMENT 'Count of bad conditions met (0-4); see methodology.md',
    is_problematic                    TINYINT(1)          NOT NULL COMMENT '1 = problem_score >= 2; 0 = clean',

    -- -------------------------------------------------------
    -- TIME DERIVED COLUMNS
    -- -------------------------------------------------------
    year_val                          SMALLINT            NULL     COMMENT 'Year extracted from timestamp; NULL for row 422',
    month_val                         TINYINT             NULL     COMMENT 'Month 1-12; NULL for row 422',
    day_val                           TINYINT             NULL     COMMENT 'Day of month; NULL for row 422',
    hour_val                          TINYINT             NULL     COMMENT 'Hour 0-23; NULL for row 422',
    weekday                           VARCHAR(10)         NULL     COMMENT 'Day name (Monday-Sunday); NULL for row 422',
    is_weekend                        TINYINT(1)          NULL     COMMENT '1=Saturday or Sunday; 0=weekday; NULL for row 422',

    -- -------------------------------------------------------
    -- CONSTRAINTS
    -- -------------------------------------------------------
    PRIMARY KEY (id),

    -- Indexes for common query patterns
    INDEX idx_environment           (environment),
    INDEX idx_tower_id              (tower_id),
    INDEX idx_user_id               (user_id),
    INDEX idx_call_type             (call_type),
    INDEX idx_direction             (direction),
    INDEX idx_signal_quality_cat    (signal_quality_category),
    INDEX idx_is_problematic        (is_problematic),
    INDEX idx_problem_score         (problem_score),
    INDEX idx_timestamp             (timestamp),
    INDEX idx_month_val             (month_val),
    INDEX idx_hour_val              (hour_val),

    -- Composite indexes for common filter combinations
    INDEX idx_env_quality           (environment, signal_quality_category),
    INDEX idx_tower_quality         (tower_id, signal_quality_category),
    INDEX idx_tower_problem         (tower_id, is_problematic),
    INDEX idx_env_problem           (environment, is_problematic),

    -- Constraints
    CONSTRAINT chk_environment      CHECK (environment IN ('urban','suburban','home','open')),
    CONSTRAINT chk_call_type        CHECK (call_type IN ('data','voice')),
    CONSTRAINT chk_direction        CHECK (direction IN ('incoming','outgoing')),
    CONSTRAINT chk_signal_quality   CHECK (signal_quality_category IN ('Excellent','Good','Fair','Poor')),
    CONSTRAINT chk_snr_cat          CHECK (snr_category IN ('High','Moderate','Low')),
    CONSTRAINT chk_att_cat          CHECK (attenuation_category IN ('Low','Medium','High')),
    CONSTRAINT chk_dist_cat         CHECK (distance_category IN ('Near','Mid','Far')),
    CONSTRAINT chk_tower_id         CHECK (tower_id BETWEEN 1 AND 10),
    CONSTRAINT chk_user_id          CHECK (user_id BETWEEN 1 AND 100),
    CONSTRAINT chk_problem_score    CHECK (problem_score BETWEEN 0 AND 4),
    CONSTRAINT chk_is_problematic   CHECK (is_problematic IN (0,1)),
    CONSTRAINT chk_is_weekend       CHECK (is_weekend IN (0,1) OR is_weekend IS NULL)

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Cleaned cellular network performance measurements. Source: Kaggle suraj520/cellular-network-performance-data';


-- =============================================================
-- LOAD DATA FROM CSV
-- =============================================================
-- Option A: Use MySQL LOAD DATA (adjust path as needed)
-- NOTE: Set LOCAL_INFILE = 1 if required.
--
-- LOAD DATA LOCAL INFILE '/path/to/data/cleaned/train_cleaned.csv'
-- INTO TABLE network_measurements
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (timestamp, signal_strength_dbm, snr, call_duration_s, environment,
--  attenuation, distance_to_tower_km, tower_id, user_id, call_type, direction,
--  signal_strength_dbm_outlier_flag, snr_outlier_flag, call_duration_s_outlier_flag,
--  attenuation_outlier_flag, distance_to_tower_km_outlier_flag,
--  signal_quality_category, snr_category, attenuation_category, distance_category,
--  problem_score, is_problematic,
--  year_val, month_val, day_val, hour_val, weekday, is_weekend);
--
-- Option B: Use MySQL Workbench Table Import Wizard
-- (recommended for Windows users — import train_cleaned.csv directly)
-- =============================================================


-- =============================================================
-- VERIFY LOAD
-- =============================================================
-- Run after loading data:
-- SELECT COUNT(*) AS total_rows FROM network_measurements;
-- Expected: 463


-- =============================================================
-- LOOKUP / REFERENCE TABLES (optional, for Power BI relationships)
-- =============================================================

CREATE TABLE IF NOT EXISTS ref_signal_quality (
    category        VARCHAR(15) NOT NULL PRIMARY KEY,
    dbm_min         DECIMAL(8,2),
    dbm_max         DECIMAL(8,2),
    description     VARCHAR(100),
    display_order   TINYINT
) COMMENT 'Signal quality category reference';

INSERT INTO ref_signal_quality VALUES
    ('Excellent', -70.00,    0.00, 'Excellent signal; full service',        1),
    ('Good',      -85.00,  -70.01, 'Good signal; reliable service',         2),
    ('Fair',     -100.00,  -85.01, 'Fair signal; marginal service',         3),
    ('Poor',     -200.00, -100.01, 'Poor signal; service unreliable',       4);


CREATE TABLE IF NOT EXISTS ref_environment (
    environment     VARCHAR(20) NOT NULL PRIMARY KEY,
    description     VARCHAR(100),
    display_order   TINYINT
) COMMENT 'Environment type reference';

INSERT INTO ref_environment VALUES
    ('home',     'Indoor home environment',          1),
    ('open',     'Open outdoor environment',         2),
    ('suburban', 'Suburban outdoor environment',     3),
    ('urban',    'Urban (city centre) environment',  4);
