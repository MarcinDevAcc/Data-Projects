# E-Commerce Warehouse KPI Analysis - SQL Project

## Overview

End-to-end warehouse analytics project built on a synthetic e-commerce dataset.  
The project covers the full data pipeline — from realistic data generation through SQL-based cleaning to KPI analysis — with a focus on operational logistics metrics used in real warehouse management systems (WMS).

Key KPIs analyzed: **Return Rate**, **Lead Time**, **Order Cycle Time**, **Fill Rate**, **Cost per Shipment**

---

## Dataset Scope

### Generated Data Profile
- **15 000 customer orders** across 12 months (2023)
- **500 SKUs** across 5 product categories with ABC classification
- **1 200 purchase orders** to 15 suppliers from 5 countries
- **50 warehouse employees** across 4 operational roles
- **9 relational tables** covering full warehouse operation lifecycle
- **~45 000 records** total across all tables

### Data Model — Table Overview

| Table | Records | Description |
|---|---|---|
| `suppliers` | 15 | Supplier master data with lead time and reliability |
| `skus` | 500 | Product catalog with ABC classification |
| `employees` | 50 | Warehouse staff with roles and shifts |
| `purchase_orders` | 1 200 | Replenishment orders to suppliers |
| `receiving_log` | 1 200 | Inbound deliveries with quantity and putaway data |
| `inventory` | 448 | Current stock levels per SKU |
| `customer_orders` | 15 000 | Customer orders with status and channel |
| `pick_orders` | 14 285 | Pick accuracy and fulfillment data |
| `shipments` | 13 526 | Outbound shipments with carrier and delivery data |

### Product Categories
- Electronics, Clothing, Sports, Home & Garden, Beauty
- ABC segmentation: **A** (100 SKUs — top revenue drivers), **B** (150 SKUs), **C** (250 SKUs)

### Sales Channels
- Website (50%), Mobile App (35%), Marketplace (15%)

### Carrier Mix
- DPD, InPost, DHL, UPS

---

## Warehouse Process Coverage

The dataset and analysis cover the full warehouse operation flow:

```
SUPPLIER → [RECEIVING] → [PUTAWAY] → [STORAGE] → [PICKING] → [SHIPPING] → CUSTOMER
```

| Process | Tables Used | KPI Measured |
|---|---|---|
| Inbound / Receiving | purchase_orders, receiving_log, suppliers | Fill Rate, Supplier Lead Time |
| Inventory Management | inventory, skus | Stock Levels, ABC Analysis |
| Order Fulfillment | customer_orders, pick_orders | Pick Accuracy, Order Cycle Time |
| Outbound / Shipping | shipments, customer_orders | Lead Time, On-Time Rate, CPS |
| Returns | customer_orders | Return Rate, Financial Impact |

---

## KPI Analysis

### Return Rate
**Definition**: Returned orders / total orders × 100  
**Purpose**: Measures how often customers return products — identifies hidden costs beyond lost revenue

| Dimension | Key Finding |
|---|---|
| Overall | 5.06% — within e-commerce benchmark of 5-10% |
| Worst category | Home & Garden (5.53%), Sports (5.50%) |
| Best category | Clothing (4.29%) |
| Best channel | Marketplace (4.59%) |
| Peak month | July (5.75%), December (5.67%) |
| Highest financial impact | Electronics — 164 705 zł lost, avg returned order 1 229 zł |

---

### Lead Time & Order Cycle Time (OCT)
**Lead Time definition**: order_date → actual delivery date (includes transport)  
**OCT definition**: order_date → ship_date (warehouse processing only)  
**Purpose**: Separating OCT from Lead Time identifies whether delays originate in the warehouse or with the carrier

| Dimension | Key Finding |
|---|---|
| Avg Lead Time | 2.96 days |
| Avg OCT | 0.48 days (~12 hours) |
| Transport share | 84% of total Lead Time |
| Fastest carrier | UPS — 2.84 days avg, 94.76% on-time |
| Slowest carrier | DPD — 3.04 days avg, 88.09% on-time |
| DPD P95 | 6 days — every 20th shipment severely delayed |
| OCT stability | Stable at 19-20h even during Q4 peak (1 876 orders/month) |

---

### Fill Rate
**Definition**: received_qty / ordered_qty × 100  
**Purpose**: Measures how completely suppliers fulfill purchase orders — low Fill Rate signals stockout risk and lost sales

| Dimension | Key Finding |
|---|---|
| Overall | 95.57% — below industry benchmark of 98% |
| Total unfulfilled | 14 552 units across all suppliers |
| Worst supplier | ShanghaiGoods Ltd. (93.78%) — also worst Lead Time delay |
| Best supplier | RomaTrade S.r.l. (97.25%) |
| Worst category | Sports (94.10%) — also highest Return Rate |
| Class A Fill Rate | 95.82% — top revenue SKUs affected by supply gaps |
| Worst SKU | SKU-0500 Clothing (74.28%) |

---

### Cost per Shipment (CPS)
**Definition**: total shipping cost / number of shipments  
**Purpose**: Measures logistics cost efficiency — rising CPS with rising volume signals scaling problems

| Dimension | Key Finding |
|---|---|
| Overall avg CPS | 14.68 zł |
| Cheapest carrier | InPost — 10.01 zł, 90.78% on-time |
| Most expensive | UPS — 24.95 zł, 94.76% on-time |
| CPS trend | Flat throughout year — no economies of scale achieved |
| Beauty category | Shipping = 6.46% of order value — highest margin erosion |
| Electronics | Shipping = 1.10% of order value — lowest margin erosion |
| Orders under 50 zł | Shipping = 42.93% of order value — unprofitable segment |
| Best efficiency score | InPost (90.69) — 2.4x higher than UPS (37.98) |

---

## SQL Techniques Demonstrated

| Technique | Where Applied |
|---|---|
| `JOIN` (multi-table) | All KPI files — connecting orders, shipments, SKUs, suppliers |
| `CTE` | Percentile calculations in Lead Time analysis |
| `Window Functions` (`PERCENT_RANK`, `PARTITION BY`) | Lead Time P50/P90/P95 by carrier |
| `CASE WHEN` | Return Rate calculation, order value bucketing in CPS |
| `DATE_FORMAT`, `DATEDIFF`, `TIMEDIFF`, `HOUR` | Lead Time, OCT, monthly trends |
| `GROUP BY` + `HAVING` | SKU-level analysis with minimum order threshold |
| `UNION ALL` | Data validation summary queries |
| `Subqueries` | Ranked percentile calculations |
| `LOAD DATA INFILE` | Bulk CSV import with boolean conversion |
| `IF` / `SET` during import | Converting True/False CSV values to 1/0 |

---

## Data Cleaning

Data quality was validated across 6 dimensions before KPI analysis:

| Check | Result |
|---|---|
| NULL values in critical columns | None found |
| Date hierarchy violations (order → ship → delivery) | None found |
| Duplicate orders or shipments | None found |
| Negative quantities or prices | None found |
| Supplier over-deliveries (received > ordered) | None found |
| Unexpected categorical values | None found — all statuses, channels, carriers valid |

---

## Key Business Insights

1. **Sports is the most problematic category** — lowest Fill Rate (94.10%) combined with second highest Return Rate (5.50%) creates double margin pressure

2. **ShanghaiGoods Ltd. is the highest supply chain risk** — worst Fill Rate (93.78%) AND worst supplier Lead Time delay (+2.7 days) among all 15 suppliers

3. **DPD P95 Lead Time reaches 6 days** — average metrics hide severe tail delays; every 20th DPD shipment takes 2x longer than UPS at P95

4. **Warehouse scales efficiently** — OCT remained stable at ~19 hours even as volume doubled from 807 to 1 876 shipments/month in Q4

5. **583 orders below 50 zł are unprofitable** — shipping cost represents 42.93% of order value; free shipping threshold at 100 zł recommended

6. **InPost offers best cost-to-reliability ratio** — efficiency score of 90.69 vs DPD's 68.03; volume shift from DPD to InPost could save ~10 800 zł annually

7. **3 Class A SKUs below 81% Fill Rate** — top revenue-driving products (SKU-0259, SKU-0278, SKU-0136) have critical supply gaps directly impacting 80% of revenue

---

## Tools & Technologies

- **Database**: MySQL 8.0
- **Data Generation**: Python 3 (pandas, numpy, faker)
- **Development**: MySQL Workbench, Jupyter Notebook, VS Code
- **SQL Features Used**: Window functions, CTEs, date functions, LOAD DATA INFILE

---

## Files Structure

```
warehouse-analytics/
│
├── data/
│   └── raw/                          # Generated CSV files (9 tables)
│       ├── suppliers.csv
│       ├── skus.csv
│       ├── employees.csv
│       ├── purchase_orders.csv
│       ├── receiving_log.csv
│       ├── inventory.csv
│       ├── customer_orders.csv
│       ├── pick_orders.csv
│       └── shipments.csv
│
├── notebooks/
│   └── 1_data_generation.ipynb       # Synthetic dataset generation (run once)
│
├── sql/
│   ├── schema.sql                    # Database and table definitions
│   ├── 1_data_import.sql             # CSV import with setup instructions
│   ├── 2_data_cleaning.sql           # Data quality validation
│   ├── 3_return_rate.sql             # Return Rate KPI analysis
│   ├── 4_lead_time.sql               # Lead Time & OCT analysis
│   ├── 5_fill_rate.sql               # Fill Rate analysis
│   └── 6_cost_per_shipment.sql       # Cost per Shipment analysis
│
└── README.md
```

---

## Setup Instructions

1. Run `schema.sql` in MySQL Workbench to create `warehouse_db` database and all tables
2. Check your MySQL upload path:
   ```sql
   SHOW VARIABLES LIKE 'secure_file_priv';
   ```
3. Copy all CSV files from `data/raw/` to the path returned in step 2
4. Update file paths in `1_data_import.sql` and run to load all data
5. Run `2_data_cleaning.sql` to validate data quality
6. Run KPI analysis files (3-6) in any order

---

## Future Enhancement Opportunities

- **Power BI Dashboard**: Visualize KPIs with monthly trend charts and carrier comparison
- **Demand Forecasting**: Predict stockouts using historical order patterns per SKU
- **Supplier Scorecard**: Automate monthly Fill Rate and Lead Time reporting per supplier
- **ABC-XYZ Analysis**: Combine ABC classification with demand variability (XYZ) for advanced inventory segmentation
- **Pick Accuracy Analysis**: Deep dive into picker performance and error type trends
