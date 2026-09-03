-- =========================================================
-- 05_staging_dim_seller.sql
-- Dimensión de vendedores. Copia directa desde raw.sellers.
-- =========================================================

CREATE TABLE analytics.dim_seller (
    seller_id               VARCHAR(64) PRIMARY KEY,
    seller_zip_code_prefix  VARCHAR(10),
    seller_city             VARCHAR(100),
    seller_state             VARCHAR(2)
);

INSERT INTO analytics.dim_seller (seller_id, seller_zip_code_prefix, seller_city, seller_state)
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM raw.sellers;