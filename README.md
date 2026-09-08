# E-commerce Revenue & Customer Analytics

Análisis end-to-end de un e-commerce brasileño real (dataset público Olist), construido con SQL como protagonista, Python como apoyo exploratorio, y Power BI para la capa de visualización de negocio.

## Business Problem

La dirección de una empresa de e-commerce necesita entender dónde gana dinero, dónde lo pierde, y qué debería priorizar: ¿los clientes vuelven a comprar? ¿qué categorías son realmente rentables? ¿la logística afecta a la satisfacción del cliente? Este proyecto responde a esas preguntas con un pipeline analítico completo, desde datos crudos hasta un dashboard ejecutivo.

## Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — ~100.000 pedidos entre septiembre de 2016 y octubre de 2018, con información de clientes, productos, vendedores, pagos, reviews y geografía.

**Nota:** los archivos CSV no se incluyen en este repositorio por tamaño. Para reproducir el proyecto, descarga el dataset desde el enlace anterior y colócalo en la carpeta `data/`.

## Data Architecture

```
CSV (Kaggle)
     ↓
PostgreSQL — capa raw (réplica tipada de los CSV originales)
     ↓
PostgreSQL — capa analytics (modelo en estrella)
     ↓
SQL Analysis (15 queries de negocio)
     ↓
Python (EDA + visualizaciones de apoyo)
     ↓
Power BI (dashboard de 3 páginas)
```

### Modelo en estrella

- **`fact_orders`** — grano: una línea de producto vendida. Incluye todos los pedidos (cualquier `order_status`), con `price`, `freight_value` y `delivery_time_days` calculado.
- **`dim_customer`** — clientes, distinguiendo `customer_id` (por pedido) de `customer_unique_id` (persona real), clave para el análisis de recurrencia.
- **`dim_product`** — productos con categoría traducida al inglés (con traducción manual documentada para 2 categorías sin traducción oficial).
- **`dim_seller`** — vendedores.
- **`dim_date`** — generada desde cero con `generate_series`, con columnas derivadas (año, mes, trimestre, fin de semana).
- **`dim_review`** — reviews deduplicadas por pedido (547 pedidos tenían más de una review; se conserva la más reciente vía `ROW_NUMBER()`).

## SQL Analysis

15 queries de negocio organizadas en 4 bloques (`sql/07` a `sql/10`), cubriendo desde SQL básico hasta window functions:

- **Básico:** `SELECT`, `WHERE`, `GROUP BY`, `CASE WHEN`
- **Intermedio:** `JOIN`, CTEs (`WITH`), `HAVING`, subqueries
- **Avanzado:** window functions — `LAG()`, `RANK()`, `ROW_NUMBER()`, `PERCENTILE_CONT()`

Bloques de análisis: **Revenue** (evolución mensual, top categorías, top estados, estacionalidad), **Customers** (nuevos vs recurrentes, tasa de repetición, tiempo entre pedidos, CLV aproximado), **Products** (volumen, ticket medio, cruce volumen/valor, reviews por categoría), **Operations** (estadísticas de entrega, entrega vs review score, ranking de estados).

## Python Analysis

Python se usó exclusivamente para EDA (calidad de datos: nulos, duplicados, integridad referencial, consistencia) y para 3 visualizaciones de apoyo — nunca como motor de análisis. Ver `notebooks/exploratory_analysis.ipynb`.

## Power BI Dashboard

Dashboard de 3 páginas conectado directamente a PostgreSQL:

1. **Executive Overview** — 7 KPIs (Revenue, Orders, Customers, AOV, Repeat Rate, Avg. Delivery Time, Avg. Review Score) + evolución temporal.
2. **Customer & Product Analytics** — filtros por fecha/región/categoría, revenue por categoría (top 10), clientes nuevos vs recurrentes.
3. **Operations** — relación entre tiempo de entrega y review score, ranking de estados por tiempo de entrega.

## Key Findings

1. **La retención es la principal oportunidad de crecimiento.** Solo el ~3% de los clientes reales (`customer_unique_id`) repite compra, y cuando lo hace, tarda de media 79 días en volver. El CLV aproximado (141,62€) es, en la práctica, casi el ticket de una única compra para la mayoría de la base de clientes.

2. **Los retrasos en la entrega hunden la satisfacción a partir de un umbral crítico de 15 días.** El review score cae de forma moderada hasta ese punto (4,37 → 4,16 estrellas), pero se desploma con fuerza a partir de ahí (3,52 estrellas), casi el triple de caída que en los tramos anteriores.

3. **El negocio está geográficamente muy concentrado, y de forma contradictoria con la logística.** São Paulo genera casi 3 veces más revenue que el segundo estado (Río de Janeiro) y disfruta además del mejor tiempo de entrega del país (8,3 días). Los estados de la región norte (Roraima, Amapá, Amazonas) combinan bajo revenue con los peores tiempos de entrega (26-28 días).

4. **Hay categorías con alto volumen y bajo valor unitario, y viceversa.** `electronics` y `telephony` mueven volúmenes altos con tickets medios bajos (56-70€), mientras que `computers` tiene el ticket medio más alto del catálogo (1.099€) pero un volumen marginal (199 unidades).

## Business Recommendations

- **Priorizar campañas de retención** dirigidas a clientes de alto valor, dado el bajo porcentaje de recompra detectado.
- **Investigar la cadena logística en las regiones norte del país**, donde los tiempos de entrega superan ampliamente la media nacional.
- **Revisar la estrategia de pricing e inventario** en categorías de alto volumen y bajo ticket medio (`electronics`, `telephony`), y evaluar el potencial de crecimiento de categorías de alto valor y bajo volumen (`computers`).
- **Establecer alertas operativas para pedidos que superen los 15 días** de tiempo de entrega estimado, dado el impacto desproporcionado en la satisfacción a partir de ese umbral.

## Tech Stack

- **Base de datos:** PostgreSQL 16 (WSL/Ubuntu)
- **SQL:** consultas analíticas, modelado dimensional, window functions
- **Python:** pandas, matplotlib (EDA y visualización de apoyo)
- **BI:** Power BI Desktop
- **Control de versiones:** Git / GitHub
- **Entorno de desarrollo:** VS Code + WSL2, DBeaver

## Estructura del repositorio

```
ecommerce-data-analytics/
│
├── data/                    # CSVs de Olist (no incluidos, ver Dataset)
├── sql/
│   ├── 01_schema.sql
│   ├── 02_staging_dim_date.sql
│   ├── 03_staging_dim_customer.sql
│   ├── 04_staging_dim_product.sql
│   ├── 05_staging_dim_seller.sql
│   ├── 06_fact_orders.sql
│   ├── 07_analysis_revenue.sql
│   ├── 08_analysis_customers.sql
│   ├── 09_analysis_products.sql
│   ├── 10_analysis_operations.sql
│   └── 11_staging_dim_review.sql
├── notebooks/
│   └── exploratory_analysis.ipynb
├── powerbi/
│   └── ecommerce_dashboard.pbix
├── src/
│   └── db_connection.py
├── README.md
└── requirements.txt
```

## Cómo reproducir el proyecto

1. Instalar PostgreSQL y crear una base de datos `ecommerce_db`.
2. Descargar el dataset Olist en `data/`.
3. Ejecutar los scripts de `sql/` en orden (01 a 11).
4. Crear un entorno virtual e instalar `requirements.txt`.
5. Configurar un archivo `.env` con las credenciales de conexión (ver `src/db_connection.py`).
6. Abrir `powerbi/ecommerce_dashboard.pbix` y actualizar la conexión a tu instancia local de PostgreSQL.