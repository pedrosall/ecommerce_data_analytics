-- =========================================================
-- 08_analysis_customers.sql
-- Preguntas de negocio: Customers
-- =========================================================

-- 1. Clientes nuevos vs recurrentes, por mes (usando customer_unique_id)
WITH primera_compra_cliente AS (
    SELECT 
        dc.customer_unique_id,
        MIN(fo.order_date_id) AS primera_compra
    FROM analytics.fact_orders fo
    JOIN analytics.dim_customer dc
        ON fo.customer_id = dc.customer_id
    WHERE fo.order_status = 'delivered'
    GROUP BY dc.customer_unique_id
),
pedidos_clasificados AS (
    SELECT DISTINCT
        dc.customer_unique_id,
        fo.order_date_id,
        pcc.primera_compra,
        CASE 
            WHEN fo.order_date_id = pcc.primera_compra THEN 'nuevo'
            ELSE 'recurrente'
        END AS tipo_cliente
    FROM analytics.fact_orders fo
    JOIN analytics.dim_customer dc
        ON fo.customer_id = dc.customer_id
    JOIN primera_compra_cliente pcc
        ON dc.customer_unique_id = pcc.customer_unique_id
    WHERE fo.order_status = 'delivered'
)
SELECT
    DATE_TRUNC('month', order_date_id) AS mes,
    tipo_cliente,
    COUNT(*) AS num_clientes
FROM pedidos_clasificados
GROUP BY DATE_TRUNC('month', order_date_id), tipo_cliente
ORDER BY mes, tipo_cliente;

-- 2. Tasa de repetición global de clientes (customer_unique_id, solo pedidos delivered)
WITH pedidos_por_cliente AS (
    SELECT
        dc.customer_unique_id,
        COUNT(DISTINCT fo.order_id) AS num_pedidos
    FROM analytics.fact_orders fo
    JOIN analytics.dim_customer dc
        ON fo.customer_id = dc.customer_id
    WHERE fo.order_status = 'delivered'
    GROUP BY dc.customer_unique_id
)
SELECT
    CASE WHEN num_pedidos = 1 THEN 'comprador_unico' ELSE 'recurrente' END AS tipo,
    COUNT(*) AS num_clientes
FROM pedidos_por_cliente
GROUP BY CASE WHEN num_pedidos = 1 THEN 'comprador_unico' ELSE 'recurrente' END;

-- 3. Tiempo medio entre pedidos, para clientes con más de un pedido (window function: LAG)
WITH pedidos_unicos AS (
    SELECT DISTINCT
        dc.customer_unique_id,
        fo.order_id,
        fo.order_date_id
    FROM analytics.fact_orders fo
    JOIN analytics.dim_customer dc
        ON fo.customer_id = dc.customer_id
    WHERE fo.order_status = 'delivered'
),
con_fecha_anterior AS (
    SELECT
        customer_unique_id,
        order_id,
        order_date_id,
        LAG(order_date_id) OVER (PARTITION BY customer_unique_id ORDER BY order_date_id) AS fecha_pedido_anterior
    FROM pedidos_unicos
)
SELECT
    AVG(order_date_id - fecha_pedido_anterior) AS dias_medios_entre_pedidos
FROM con_fecha_anterior
WHERE fecha_pedido_anterior IS NOT NULL;

-- 4. Customer Lifetime Value aproximado (gasto histórico medio por cliente)
WITH gasto_total AS (
    SELECT 
        dc.customer_unique_id, 
        COUNT(DISTINCT fo.order_id) AS numero_de_pedidos, 
        SUM(fo.price) AS gasto_total_cliente
    FROM analytics.fact_orders fo
    JOIN analytics.dim_customer dc
        ON dc.customer_id = fo.customer_id
    WHERE fo.order_status = 'delivered'
    GROUP BY dc.customer_unique_id
)
SELECT AVG(gasto_total_cliente) AS clv_aproximado
FROM gasto_total;