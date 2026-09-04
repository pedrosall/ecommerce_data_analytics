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

-- 2. Top 10 categorías por ticket medio (precio medio por unidad, solo pedidos delivered)
SELECT dp.product_category_name_english AS categoria, AVG(fo.price) AS ticket_medio
FROM analytics.fact_orders fo
JOIN analytics.dim_product dp
    ON dp.product_id = fo.product_id
WHERE fo.order_status = 'delivered'
GROUP BY dp.product_category_name_english
ORDER BY AVG(fo.price) DESC
LIMIT 10;

-- 3. Cruce de volumen y ticket medio por categoría, para detectar alto volumen / bajo valor
SELECT dp.product_category_name_english AS categoria, COUNT(fo.order_item_id) AS unidades_vendidas, AVG(fo.price) AS ticket_medio
FROM analytics.fact_orders fo
JOIN analytics.dim_product dp
    ON dp.product_id = fo.product_id
WHERE fo.order_status = 'delivered'
GROUP BY dp.product_category_name_english
ORDER BY COUNT(fo.order_item_id) DESC;

-- 4. Top 10 categorías con peor review_score medio (sin filtro de status; ojo con muestras pequeñas)
SELECT dp.product_category_name_english AS categoria, AVG(t.review_score) AS review_score_medio, COUNT(fo.order_id) AS numero_reviews
FROM analytics.fact_orders fo
JOIN analytics.dim_product dp
    ON dp.product_id = fo.product_id
JOIN raw.order_reviews t
    ON t.order_id = fo.order_id
GROUP BY dp.product_category_name_english
ORDER BY AVG(t.review_score) ASC
LIMIT 10;