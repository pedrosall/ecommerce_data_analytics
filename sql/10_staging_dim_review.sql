-- =========================================================
-- 11_staging_dim_review.sql
-- Dimensión de reviews, deduplicada por pedido.
-- Hallazgo: 547 pedidos tenían más de una review (el cliente
-- actualizó su valoración con el tiempo). Nos quedamos con la
-- review más reciente por pedido (ROW_NUMBER + review_answer_timestamp).
-- =========================================================

CREATE TABLE analytics.dim_review AS
WITH reviews_numeradas AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_answer_timestamp DESC) AS rn
    FROM raw.order_reviews
)
SELECT * FROM reviews_numeradas
WHERE rn = 1;