-- =========================================================
-- 01_schema.sql
-- Capa RAW: réplica tipada de los CSV originales de Olist.
-- Sin limpieza de negocio todavía (eso vive en 02_cleaning.sql)
-- =========================================================

CREATE SCHEMA IF NOT EXISTS raw;

CREATE TABLE raw.customers (
    customer_id               VARCHAR(64) PRIMARY KEY,
    customer_unique_id        VARCHAR(64),
    customer_zip_code_prefix  VARCHAR(10),
    customer_city             VARCHAR(100),
    customer_state            VARCHAR(2)
);

CREATE TABLE raw.geolocation (
    geolocation_zip_code_prefix  VARCHAR(10),
    geolocation_lat              NUMERIC,
    geolocation_lng              NUMERIC,
    geolocation_city             VARCHAR(100),
    geolocation_state            VARCHAR(2)
);

CREATE TABLE raw.sellers (
    seller_id               VARCHAR(64) PRIMARY KEY,
    seller_zip_code_prefix  VARCHAR(10),
    seller_city              VARCHAR(100),
    seller_state             VARCHAR(2)
);

CREATE TABLE raw.products (
    product_id                     VARCHAR(64) PRIMARY KEY,
    product_category_name          VARCHAR(100),
    product_name_lenght            NUMERIC,
    product_description_lenght     NUMERIC,
    product_photos_qty             NUMERIC,
    product_weight_g               NUMERIC,
    product_length_cm              NUMERIC,
    product_height_cm              NUMERIC,
    product_width_cm               NUMERIC
);

CREATE TABLE raw.orders (
    order_id                        VARCHAR(64) PRIMARY KEY,
    customer_id                     VARCHAR(64),
    order_status                    VARCHAR(20),
    order_purchase_timestamp        TIMESTAMP,
    order_approved_at               TIMESTAMP,
    order_delivered_carrier_date    TIMESTAMP,
    order_delivered_customer_date   TIMESTAMP,
    order_estimated_delivery_date   TIMESTAMP
);

CREATE TABLE raw.order_items (
    order_id              VARCHAR(64),
    order_item_id         INTEGER,
    product_id            VARCHAR(64),
    seller_id             VARCHAR(64),
    shipping_limit_date   TIMESTAMP,
    price                 NUMERIC,
    freight_value         NUMERIC,
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE raw.order_payments (
    order_id               VARCHAR(64),
    payment_sequential     INTEGER,
    payment_type           VARCHAR(20),
    payment_installments   INTEGER,
    payment_value          NUMERIC,
    PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE raw.order_reviews (
    review_id                  VARCHAR(64),
    order_id                   VARCHAR(64),
    review_score                INTEGER,
    review_comment_title        TEXT,
    review_comment_message      TEXT,
    review_creation_date        TIMESTAMP,
    review_answer_timestamp     TIMESTAMP
);

CREATE TABLE raw.category_translation (
    product_category_name           VARCHAR(100) PRIMARY KEY,
    product_category_name_english   VARCHAR(100)
);