-- =========================================================
-- 06_fact_orders.sql
-- Tabla de hechos: una fila = una línea de producto vendida.
-- Incluye TODOS los pedidos (cualquier order_status).
-- delivery_time_days queda NULL si el pedido no tiene fecha de entrega.
-- =========================================================

CREATE TABLE analytics.fact_orders (
    order_id              VARCHAR(64),
    order_item_id         INTEGER,
    customer_id           VARCHAR(64) REFERENCES analytics.dim_customer(customer_id),
    product_id            VARCHAR(64) REFERENCES analytics.dim_product(product_id),
    seller_id             VARCHAR(64) REFERENCES analytics.dim_seller(seller_id),
    order_date_id         DATE REFERENCES analytics.dim_date(date_id),
    order_status          VARCHAR(20),
    price                 NUMERIC,
    freight_value         NUMERIC,
    delivery_time_days    INTEGER,
    PRIMARY KEY (order_id, order_item_id)
);

INSERT INTO analytics.fact_orders (order_id, order_item_id, customer_id, product_id, seller_id, order_date_id, order_status, price, freight_value, delivery_time_days)
SELECT
    oi.order_id,
    oi.order_item_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,
    o.order_purchase_timestamp::DATE AS order_date_id,
    o.order_status,
    oi.price,
    oi.freight_value,
    DATE_PART('day', o.order_delivered_customer_date - o.order_purchase_timestamp)::INTEGER AS delivery_time_days
FROM raw.order_items oi
JOIN raw.orders o
    ON oi.order_id = o.order_id;