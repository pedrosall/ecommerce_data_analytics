-- =========================================================
-- 07_analysis_revenue.sql
-- Preguntas de negocio: Revenue
-- =========================================================

-- 1. Evolución de revenue mensual (solo pedidos delivered)
SELECT
    DATE_TRUNC('month', order_date_id) AS mes,
    SUM(price) AS revenue_total
FROM analytics.fact_orders
WHERE order_status = 'delivered'
GROUP BY DATE_TRUNC('month', order_date_id)
ORDER BY mes;

-- 2. Top 10 categorías por revenue (solo pedidos delivered)
select dp.product_category_name_english, SUM(fo.price) as revenue_total
from analytics.fact_orders fo
join analytics.dim_product dp 
	on dp.product_id = fo.product_id
where fo.order_status ='delivered'
group by dp.product_category_name_english
order by revenue_total DESC

-- 3. Top 10 estados (regiones) por revenue (solo pedidos delivered)
select c.customer_state as estado, SUM(fo.price) as revenue_total
from analytics.fact_orders fo 
join analytics.dim_customer c 
	on c.customer_id = fo.customer_id
where fo.order_status = 'delivered'
group by c.customer_state 
order by fo.price desc 

-- 4. Estacionalidad: revenue agregado por mes del calendario (todos los años juntos)
SELECT EXTRACT(MONTH FROM order_date_id) AS mes, SUM(price) AS revenue_total
FROM analytics.fact_orders
WHERE order_status = 'delivered'
GROUP BY EXTRACT(MONTH FROM order_date_id)
ORDER BY EXTRACT(MONTH FROM order_date_id) ASC;

-- 4b. Verificación de cobertura: cuántos años distintos aportan datos a cada mes
-- (noviembre solo tiene 1 año de cobertura, su cifra no es directamente comparable con el resto)
SELECT 
    EXTRACT(MONTH FROM order_date_id) AS mes,
    COUNT(DISTINCT EXTRACT(YEAR FROM order_date_id)) AS anios_con_datos
FROM analytics.fact_orders
WHERE order_status = 'delivered'
GROUP BY EXTRACT(MONTH FROM order_date_id)
ORDER BY mes;