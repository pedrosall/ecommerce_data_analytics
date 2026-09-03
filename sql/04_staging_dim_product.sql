-- =========================================================
-- 04_staging_dim_product.sql
-- Dimensión de productos, con categoría ya traducida al inglés.
-- LEFT JOIN para no perder productos aunque falte traducción.
-- =========================================================

CREATE TABLE analytics.dim_product (
    product_id                     VARCHAR(64) PRIMARY KEY,
    product_category_name          VARCHAR(100),
    product_category_name_english  VARCHAR(100),
    product_weight_g               NUMERIC,
    product_length_cm              NUMERIC,
    product_height_cm              NUMERIC,
    product_width_cm               NUMERIC
);

INSERT INTO analytics.dim_product (product_id, product_category_name, product_category_name_english, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
SELECT
    p.product_id,
    p.product_category_name,
    COALESCE(
        ct.product_category_name_english,
        CASE 
            WHEN p.product_category_name = 'pc_gamer' THEN 'pc_gamer'
            WHEN p.product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos' THEN 'portable_kitchen_and_food_preparers'
            ELSE NULL
        END
    ) AS product_category_name_english,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM raw.products p
LEFT JOIN raw.category_translation ct
    ON p.product_category_name = ct.product_category_name;