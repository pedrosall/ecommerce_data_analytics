-- =========================================================
-- 09_analysis_products.sql
-- Preguntas de negocio: Products
-- =========================================================

-- 1. Top 10 categorías por volumen de unidades vendidas (solo pedidos delivered)
SELECT dp.product_category_name_english AS categoria, COUNT(fo.order_item_id) AS unidades_vendidas
FROM analytics.fact_orders fo
JOIN analytics.dim_product dp
    ON dp.product_id = fo.product_id
WHERE fo.order_status = 'delivered'
GROUP BY dp.product_category_name_english
ORDER BY COUNT(fo.order_item_id) DESC
LIMIT 10;