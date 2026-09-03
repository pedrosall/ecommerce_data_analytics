-- =========================================================
-- 03_staging_dim_customer.sql
-- Dimensión de clientes. customer_id = por pedido, 
-- customer_unique_id = identifica a la persona real (para análisis de recurrencia)
-- =========================================================

CREATE TABLE analytics.dim_customer (
    customer_id               VARCHAR(64) PRIMARY KEY,
    customer_unique_id        VARCHAR(64),
    customer_zip_code_prefix  VARCHAR(10),
    customer_city             VARCHAR(100),
    customer_state            VARCHAR(2)
);

INSERT INTO analytics.dim_customer (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM raw.customers;