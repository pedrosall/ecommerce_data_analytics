-- =========================================================
-- 02_staging_dim_date.sql
-- Genera la dimensión de fechas, cubriendo 2016-01-01 a 2018-12-31
-- No depende de ningún CSV: se construye desde cero con generate_series.
-- =========================================================

CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE analytics.dim_date (
    date_id             DATE PRIMARY KEY,
    year                INTEGER,
    month               INTEGER,
    month_name          VARCHAR(20),
    day                 INTEGER,
    day_of_week         INTEGER,
    day_name            VARCHAR(20),
    quarter             INTEGER,
    is_weekend          BOOLEAN
);

INSERT INTO analytics.dim_date (date_id, year, month, month_name, day, day_of_week, day_name, quarter, is_weekend)
SELECT
    d::DATE AS date_id,
    EXTRACT(YEAR FROM d)::INTEGER AS year,
    EXTRACT(MONTH FROM d)::INTEGER AS month,
    TO_CHAR(d, 'Month') AS month_name,
    EXTRACT(DAY FROM d)::INTEGER AS day,
    EXTRACT(DOW FROM d)::INTEGER AS day_of_week,
    TO_CHAR(d, 'Day') AS day_name,
    EXTRACT(QUARTER FROM d)::INTEGER AS quarter,
    CASE WHEN EXTRACT(DOW FROM d) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend
FROM generate_series('2016-01-01'::DATE, '2018-12-31'::DATE, '1 day') AS d;