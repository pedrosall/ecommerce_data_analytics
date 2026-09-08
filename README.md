# E-commerce Revenue & Customer Analytics

End-to-end analysis of a real Brazilian e-commerce business (public Olist dataset), built with SQL as the core tool, Python for exploratory support, and Power BI as the business-facing visualization layer.

## Business Problem

The leadership of an e-commerce company needs to understand where it makes money, where it loses money, and what to prioritize: do customers come back? which categories are actually profitable? does logistics affect customer satisfaction? This project answers these questions through a complete analytics pipeline, from raw data to an executive dashboard.

## Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — ~100,000 orders between September 2016 and October 2018, including customer, product, seller, payment, review, and geolocation data.

**Note:** the CSV files are not included in this repository due to size. To reproduce the project, download the dataset from the link above and place it in the `data/` folder.

## Data Architecture

```
CSV (Kaggle)
     ↓
PostgreSQL — raw layer (typed replica of the original CSVs)
     ↓
PostgreSQL — analytics layer (star schema)
     ↓
SQL Analysis (15 business queries)
     ↓
Python (EDA + supporting visualizations)
     ↓
Power BI (3-page dashboard)
```

### Star Schema

- **`fact_orders`** — grain: one product line item sold. Includes all orders (any `order_status`), with `price`, `freight_value`, and a calculated `delivery_time_days`.
- **`dim_customer`** — customers, distinguishing `customer_id` (per order) from `customer_unique_id` (the actual person), key for repeat-purchase analysis.
- **`dim_product`** — products with category translated into English (including a manual, documented translation for 2 categories missing an official one).
- **`dim_seller`** — sellers.
- **`dim_date`** — generated from scratch with `generate_series`, with derived columns (year, month, quarter, weekend flag).
- **`dim_review`** — reviews deduplicated per order (547 orders had more than one review; the most recent one is kept via `ROW_NUMBER()`).

## SQL Analysis

15 business queries organized into 4 blocks (`sql/07` to `sql/10`), covering everything from basic SQL to window functions:

- **Basic:** `SELECT`, `WHERE`, `GROUP BY`, `CASE WHEN`
- **Intermediate:** `JOIN`, CTEs (`WITH`), `HAVING`, subqueries
- **Advanced:** window functions — `LAG()`, `RANK()`, `ROW_NUMBER()`, `PERCENTILE_CONT()`

Analysis blocks: **Revenue** (monthly evolution, top categories, top states, seasonality), **Customers** (new vs returning, repeat rate, time between orders, approximate CLV), **Products** (volume, average ticket, volume/value crossover, reviews by category), **Operations** (delivery time statistics, delivery time vs review score, state ranking).

## Python Analysis

Python was used exclusively for EDA (data quality: nulls, duplicates, referential integrity, consistency) and for 3 supporting visualizations — never as the main analysis engine. See `notebooks/exploratory_analysis.ipynb`.

## Power BI Dashboard

A 3-page dashboard connected directly to PostgreSQL:

1. **Executive Overview** — 7 KPIs (Revenue, Orders, Customers, AOV, Repeat Rate, Avg. Delivery Time, Avg. Review Score) + time evolution.
2. **Customer & Product Analytics** — date/region/category filters, revenue by category (top 10), new vs returning customers.
3. **Operations** — relationship between delivery time and review score, state ranking by delivery time.

## Key Findings

1. **Retention is the main growth opportunity.** Only ~3% of actual customers (`customer_unique_id`) make a repeat purchase, and when they do, it takes an average of 79 days to come back. The approximate CLV (€141.62) is, in practice, close to the value of a single purchase for most of the customer base.

2. **Delivery delays sharply hurt satisfaction past a critical 15-day threshold.** Review scores decline moderately up to that point (4.37 → 4.16 stars), but drop sharply after it (3.52 stars) — nearly three times steeper than the previous stages.

3. **The business is heavily concentrated geographically, and at odds with logistics performance.** São Paulo generates almost 3 times more revenue than the second-highest state (Rio de Janeiro) and also enjoys the best delivery time in the country (8.3 days). Northern states (Roraima, Amapá, Amazonas) combine low revenue with the worst delivery times (26-28 days).

4. **There's a mismatch between volume and unit value across categories.** `electronics` and `telephony` move high volumes at low average tickets (€56-70), while `computers` has the highest average ticket in the catalog (€1,099) but marginal volume (199 units).

## Business Recommendations

- **Prioritize retention campaigns** targeting high-value customers, given the low repeat-purchase rate detected.
- **Investigate the logistics chain in the northern regions**, where delivery times far exceed the national average.
- **Review pricing and inventory strategy** for high-volume/low-ticket categories (`electronics`, `telephony`), and assess growth potential in high-value/low-volume categories (`computers`).
- **Set up operational alerts for orders exceeding 15 days** of estimated delivery time, given the disproportionate impact on satisfaction past that threshold.

## Tech Stack

- **Database:** PostgreSQL 16 (WSL/Ubuntu)
- **SQL:** analytical queries, dimensional modeling, window functions
- **Python:** pandas, matplotlib (EDA and supporting visualizations)
- **BI:** Power BI Desktop
- **Version control:** Git / GitHub
- **Development environment:** VS Code + WSL2, DBeaver

## Repository Structure

```
ecommerce-data-analytics/
│
├── data/                    # Olist CSVs (not included, see Dataset)
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

## How to Reproduce This Project

1. Install PostgreSQL and create an `ecommerce_db` database.
2. Download the Olist dataset into `data/`.
3. Run the scripts in `sql/` in order (01 to 11).
4. Create a virtual environment and install `requirements.txt`.
5. Set up a `.env` file with your connection credentials (see `src/db_connection.py`).
6. Open `powerbi/ecommerce_dashboard.pbix` and update the connection to your local PostgreSQL instance.
