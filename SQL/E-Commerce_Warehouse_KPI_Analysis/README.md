# E-Commerce Warehouse KPI Analysis - SQL Project

## Overview

End-to-end warehouse analytics project built on a synthetic e-commerce dataset.  
The project covers data generation, SQL-based validation, and KPI analysis across inbound, inventory, fulfillment, shipping, and returns processes.

Key KPIs analyzed: **Return Rate**, **Lead Time**, **Order Cycle Time**, **Fill Rate**, **Cost per Shipment**

> **Note**: All data in this project is synthetically generated using Python (Faker library).  
> It does not represent any real company, supplier, or business operation.  
> Carrier names (DPD, DHL, InPost, UPS) are used for illustrative purposes only, and all associated metrics are fictional.

---

## Dataset Scope

### Generated Data Profile
- **15 000 customer orders** across 12 months (2023)
- **500 SKUs** across 5 product categories with ABC classification
- **1 200 purchase orders** to 15 suppliers from 5 countries
- **50 warehouse employees** across 4 operational roles
- **9 relational tables** covering the warehouse operation lifecycle
- **~45 000 records** total across all tables

### Data Model — Table Overview

| Table | Records | Description |
|---|---:|---|
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
- Electronics
- Clothing
- Sports
- Home & Garden
- Beauty

ABC segmentation:
- **A** — 100 SKUs
- **B** — 150 SKUs
- **C** — 250 SKUs

### Sales Channels
- Website — 50%
- Mobile App — 35%
- Marketplace — 15%

### Carrier Mix
- DPD
- InPost
- DHL
- UPS

---

## Warehouse Process Coverage

The dataset and analysis cover the full warehouse operation flow:

```text
SUPPLIER → [RECEIVING] → [PUTAWAY] → [STORAGE] → [PICKING] → [SHIPPING] → CUSTOMER
```

| Process | Tables Used | KPI Measured |
|---|---|---|
| Inbound / Receiving | `purchase_orders`, `receiving_log`, `suppliers` | Fill Rate, Supplier Lead Time |
| Inventory Management | `inventory`, `skus` | Stock Levels, ABC Analysis |
| Order Fulfillment | `customer_orders`, `pick_orders` | Pick Accuracy, Order Cycle Time |
| Outbound / Shipping | `shipments`, `customer_orders` | Lead Time, On-Time Rate, CPS |
| Returns | `customer_orders` | Return Rate, Returned Order Value |

---

## KPI Analysis

### Return Rate

**Definition**: Returned orders / total orders × 100

**Purpose**: Measures the share of customer orders returned after purchase.

| Dimension | Key Finding |
|---|---|
| Overall | 5.06% |
| Highest category | Home & Garden (5.53%), Sports (5.50%) |
| Lowest category | Clothing (4.29%) |
| Lowest channel | Marketplace (4.59%) |
| Peak month | July (5.75%), December (5.67%) |
| Highest returned order value | Electronics — 164 705 zł, avg returned order 1 229 zł |

---

### Lead Time & Order Cycle Time (OCT)

**Lead Time definition**: `order_date` → actual delivery date  
**OCT definition**: `order_date` → `ship_date`

**Purpose**: Separating warehouse processing time from total delivery time helps distinguish internal fulfillment performance from carrier transit time.

| Dimension | Key Finding |
|---|---|
| Avg Lead Time | 2.96 days |
| Avg OCT | 0.48 days (~12 hours) |
| Transport share | 84% of total Lead Time |
| Fastest carrier | UPS — 2.84 days avg, 94.76% on-time |
| Slowest carrier | DPD — 3.04 days avg, 88.09% on-time |
| DPD P95 | 6 days |

---

### Fill Rate

**Definition**: `received_qty / ordered_qty × 100`

**Purpose**: Measures how completely suppliers fulfill purchase orders.

| Dimension | Key Finding |
|---|---|
| Overall | 95.57% |
| Total unfulfilled | 14 552 units |
| Lowest supplier | ShanghaiGoods Ltd. — 93.78% |
| Highest supplier | RomaTrade S.r.l. — 97.25% |
| Lowest category | Sports — 94.10% |
| Class A Fill Rate | 95.82% |
| Lowest SKU | SKU-0500 Clothing — 74.28% |

---

### Cost per Shipment (CPS)

**Definition**: Total shipping cost / number of shipments

**Purpose**: Measures average outbound shipping cost and allows comparison across carriers, categories, and order-value groups.

| Dimension | Key Finding |
|---|---|
| Overall avg CPS | 14.68 zł |
| Lowest carrier cost | InPost — 10.01 zł, 90.78% on-time |
| Highest carrier cost | UPS — 24.95 zł, 94.76% on-time |
| CPS trend | Approximately flat across the year |
| Beauty category | Shipping cost = 6.46% of order value |
| Electronics | Shipping cost = 1.10% of order value |
| Orders under 50 zł | Shipping cost = 42.93% of order value |
| Best efficiency score | InPost — 90.69 |

---

## SQL Techniques Demonstrated

| Technique | Where Applied |
|---|---|
| `JOIN` (multi-table) | KPI files connecting orders, shipments, SKUs, suppliers |
| `CTE` | Percentile calculations in Lead Time analysis |
| Window Functions (`PERCENT_RANK`, `PARTITION BY`) | Lead Time P50 / P90 / P95 by carrier |
| `CASE WHEN` | Return Rate calculation, CPS value buckets |
| `DATE_FORMAT`, `DATEDIFF`, `TIMEDIFF`, `HOUR` | Lead Time, OCT, monthly trends |
| `GROUP BY` + `HAVING` | SKU-level analysis with minimum-order thresholds |
| `UNION ALL` | Data-validation summary queries |
| Subqueries | Ranked percentile calculations |
| `LOAD DATA INFILE` | Bulk CSV import |
| `IF` / `SET` during import | Boolean conversion during CSV loading |

---

## Data Validation

Data quality was validated before KPI analysis across six dimensions:

| Check | Result |
|---|---|
| NULL values in critical columns | None found |
| Date hierarchy violations (`order → ship → delivery`) | None found |
| Duplicate orders or shipments | None found |
| Negative quantities or prices | None found |
| Supplier over-deliveries (`received > ordered`) | None found |
| Unexpected categorical values | None found |

---

## Key Business Insights

1. **Sports combines the lowest Fill Rate (94.10%) with the second-highest Return Rate (5.50%).**  
   This identifies the category as a useful candidate for deeper supplier, inventory, and product-level review.

2. **ShanghaiGoods Ltd. has the lowest supplier Fill Rate (93.78%) and the largest Lead Time delay among the 15 suppliers.**  
   Both indicators point to weaker supplier performance within the generated dataset.

3. **DPD P95 Lead Time reaches 6 days.**  
   The percentile view shows that average delivery time alone does not capture the slower tail of the carrier distribution.

4. **Orders below 50 zł have very high shipping-cost exposure.**  
   Shipping cost represents 42.93% of order value for this group, suggesting that shipping-pricing rules for low-value orders may warrant review.

5. **InPost has the strongest cost-to-reliability efficiency score in the analysis.**  
   Its score of 90.69 is higher than the other carrier results in the generated dataset.

6. **Three Class A SKUs have Fill Rate below 81%.**  
   SKU-0259, SKU-0278, and SKU-0136 show supply gaps among high-priority products.

---

## Tools & Technologies

- **Database**: MySQL 8.0
- **Data Generation**: Python 3, pandas, numpy, Faker
- **Development**: MySQL Workbench, Jupyter Notebook, VS Code
- **SQL Features**: Window functions, CTEs, date functions, `LOAD DATA INFILE`

---

## Files Structure

```text
E-Commerce_Warehouse_KPI_Analysis/
│
├── data/
│   └── raw/
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
│   └── 1_data_generation.ipynb
│
├── sql/
│   ├── schema.sql
│   ├── 1_data_import.sql
│   ├── 2_data_cleaning.sql
│   ├── 3_return_rate.sql
│   ├── 4_lead_time.sql
│   ├── 5_fill_rate.sql
│   └── 6_cost_per_shipment.sql
│
└── README.md
```

---

## Setup Instructions

1. Run `schema.sql` in MySQL Workbench to create the `warehouse_db` database and tables

2. Check the MySQL upload path:

```sql
SHOW VARIABLES LIKE 'secure_file_priv';
```

3. Copy all CSV files from `data/raw/` to the returned path

4. Update file paths in `1_data_import.sql` and run the import

5. Run `2_data_cleaning.sql` to validate data quality

6. Run KPI analysis files `3-6` in any order

---

## Future Enhancement Opportunities

- **Power BI Dashboard** — visualize warehouse KPIs and monthly trends
- **Supplier Scorecard** — automate supplier-level Fill Rate and Lead Time reporting
- **ABC-XYZ Analysis** — combine revenue classification with demand variability
- **Pick Accuracy Analysis** — analyze picker performance and error patterns
- **Demand Forecasting** — extend the project with historical demand modeling
