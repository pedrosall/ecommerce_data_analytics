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

-- =========================================================
-- 10_analysis_operations.sql
-- Preguntas de negocio: Operations
-- =========================================================

-- 1. Estadísticas generales de tiempo de entrega (solo pedidos delivered)
SELECT 
    AVG(delivery_time_days) AS tiempo_medio, 
    MIN(delivery_time_days) AS tiempo_minimo, 
    MAX(delivery_time_days) AS tiempo_maximo,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY delivery_time_days) AS tiempo_mediana
FROM analytics.fact_orders
WHERE order_status = 'delivered';

-- 2. Relación entre tiempo de entrega y review score (hallazgo central del proyecto)
SELECT 
    CASE
        WHEN fo.delivery_time_days < 5 THEN '< 5 dias'
        WHEN fo.delivery_time_days BETWEEN 5 AND 10 THEN '5-10 dias'
        WHEN fo.delivery_time_days BETWEEN 10 AND 15 THEN '10-15 dias'
        WHEN fo.delivery_time_days > 15 THEN '> 15 dias'
    END AS rango_entrega,
    AVG(t.review_score) AS review_score_medio, 
    COUNT(fo.order_id) AS numero_pedidos
FROM analytics.fact_orders fo
JOIN raw.order_reviews t
    ON t.order_id = fo.order_id
WHERE fo.order_status = 'delivered'
GROUP BY rango_entrega;

-- 3. Ranking de estados por tiempo de entrega medio (excluye estados con menos de 30 pedidos)
SELECT dc.customer_state AS estado, AVG(fo.delivery_time_days) AS tiempo_medio_entrega, COUNT(fo.order_id) AS numero_pedidos,
    RANK() OVER (ORDER BY AVG(fo.delivery_time_days) DESC) AS ranking
FROM analytics.fact_orders fo
JOIN analytics.dim_customer dc
    ON dc.customer_id = fo.customer_id
WHERE fo.order_status = 'delivered'
GROUP BY dc.customer_state
HAVING COUNT(fo.order_id) > 30
ORDER BY ranking ASC;