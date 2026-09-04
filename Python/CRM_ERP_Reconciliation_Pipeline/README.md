# CRM-ERP Reconciliation Pipeline - Python ETL Project

## Overview

Python ETL pipeline designed to reconcile sales records between CRM and ERP systems.  
The project extracts data from two independent sources — a CSV export and a REST API served by a local FastAPI mock CRM — validates and cleans the data, reconciles CRM deals against ERP orders, and loads the results into MySQL with execution logging and an audit trail.

> **Note**: All data in this project is synthetically generated using Python (Faker). It does not represent any real company, supplier, or business operation.

> **Code comments**: Source code and SQL comments are bilingual (English + Polish) for personal learning purposes. This README is English-only.

---

## Dataset Scope

### Generated Data Profile
- **200 CRM deals**
  - Won: 131
  - Open: 34
  - Lost: 35
- **274 ERP orders**
- **3 currencies**: PLN, EUR, USD
- **5 countries**: Poland, Germany, France, Spain, Italy
- **Time period**: 2025

### Intentional Discrepancies

The synthetic dataset intentionally contains reconciliation and data-quality issues so that the pipeline has verifiable cases to detect.

| Category | Design Target | Description |
|---|---|---|
| MATCHED | ~70% of Won deals | ERP order exists, amount within 1% of the CRM deal |
| AMOUNT_MISMATCH | ~15% of Won deals | ERP order exists, amount differs by 5-25% |
| CRM_ONLY | ~15% of Won deals | Won CRM deal has no corresponding ERP order |
| ERP_ONLY | 12 orders | ERP order references a `deal_id` missing from CRM |
| Organic orders | 150 orders | No CRM link, outside reconciliation scope |
| Data quality issues | 8 rows | 3 negative amounts, 3 missing `customer_id`, 2 duplicate rows |

---

## Key Features

### Multi-Source Extraction
- CSV file simulating a nightly ERP export, read with pandas
- REST API served by a local FastAPI mock CRM
- Incremental CRM extraction supported via `?since=<date>`

### Data Validation
- Detects:
  - negative amounts
  - missing customer IDs
  - duplicate order IDs
- Returns cleaned data together with issue counts for execution logging

### Currency Normalization
- Converts PLN / EUR / USD into PLN before reconciliation
- Uses a static reference-rate table

### Reconciliation Logic
- Classifies records into:
  - `MATCHED`
  - `AMOUNT_MISMATCH`
  - `CRM_ONLY`
  - `ERP_ONLY`
- Separates:
  - business-state comparison of Won deals vs ERP orders
  - data-integrity validation of ERP references against the full CRM deal list

### Incremental & Idempotent Loading
- Staging tables are truncated and reloaded on each run
- Raw extracted records are preserved in staging, including invalid rows
- Fact table uses `INSERT ... ON DUPLICATE KEY UPDATE`
- Pipeline can be re-run without duplicating reconciliation records

### Automation & Resilience
- Retry with exponential backoff using `tenacity`
- Daily scheduling via `schedule`
- Logging to file and console
- Execution details stored in the `run_log` table

---

## ETL & SQL Techniques Demonstrated

| Technique | Where Applied |
|---|---|
| Multi-source extraction (file + REST API) | `extract.py` |
| Data validation & cleaning | `validate_erp()` in `transform.py` |
| Currency normalization | `normalize_currency()` in `transform.py` |
| Outer-join reconciliation | `reconcile()` in `transform.py` |
| Upsert (`ON DUPLICATE KEY UPDATE`) | `load_fact_reconciliation()` in `load.py` |
| Staging tables (truncate-and-load) | `load_staging()` in `load.py`, `schema.sql` |
| Incremental extraction (`since` parameter) | `crm_api.py`, `extract_crm()` |
| Retry with exponential backoff | `tenacity`, `fetch_crm_deals()` in `main.py` |
| Scheduled execution | `schedule`, `main.py` |
| Execution logging | `run_log`, `log_run()` in `load.py` |

---

## Data Model

Four MySQL tables are defined in `sql/schema.sql`:

| Table | Type | Purpose |
|---|---|---|
| `stg_erp_orders` | Staging | Raw ERP export, truncated and reloaded every run |
| `stg_crm_deals` | Staging | Raw CRM deals, truncated and reloaded every run |
| `fact_reconciliation` | Fact | Clean reconciliation result, upserted on `reconciliation_key` |
| `run_log` | Audit | One row per pipeline step per batch |

---

## Example Run Result

Actual output from a full pipeline run against the generated dataset:

```text
ERP validation: 274 rows in, 266 rows out
Issues found: negative_amount: 3, null_customer_id: 3, duplicate_order_id: 2

Reconciliation result (143 rows total):
  MATCHED            89
  AMOUNT_MISMATCH    17
  CRM_ONLY           25
  ERP_ONLY           12
```

---

## Key Business Insights

1. **Data-quality issues affect reconciliation outcomes.**  
   Four of the eight ERP rows rejected during validation were linked to Won CRM deals. Removing those invalid rows changed the reconciliation result from the intended 91/19/21 MATCHED / AMOUNT_MISMATCH / CRM_ONLY split to the actual 89/17/25 result.

2. **32% of Won-deal outcomes are not clean matches.**  
   `AMOUNT_MISMATCH` + `CRM_ONLY` account for 42 of 131 Won-deal outcomes.

3. **12 ERP orders contain broken CRM references.**  
   These orders reference `deal_id` values that do not exist in the CRM dataset and are handled separately from business-status mismatches.

---

## Business Value

- **Potential invoicing-gap detection** - flags Won CRM deals without a corresponding ERP order
- **Data-integrity monitoring** - identifies broken references between systems
- **Traceable execution** - records row counts and processing status for each pipeline step
- **Reusable reconciliation pattern** - the same extract / validate / reconcile / load structure can be adapted to other system-pair comparisons

---

## Tools & Technologies

- **Language**: Python 3.13
- **Data Generation**: Faker, pandas
- **API**: FastAPI, uvicorn, pydantic
- **Database**: MySQL 8.0, MySQL Workbench, mysql-connector-python
- **Automation**: schedule, tenacity
- **Configuration**: python-dotenv
- **Development**: VS Code, Jupyter, git

---

## Files Structure

```text
CRM_ERP_Reconciliation_Pipeline/
├── mock_api/
│   └── crm_api.py
├── data/raw/
│   ├── erp_orders_export.csv
│   └── crm_deals_seed.json
├── etl/
│   ├── extract.py
│   ├── transform.py
│   ├── load.py
│   └── main.py
├── sql/
│   └── schema.sql
├── logs/
│   └── pipeline.log
├── notebooks/
│   └── data_generation.ipynb
├── requirements.txt
└── README.md
```

---

## Setup Instructions

1. Clone the repository and navigate to `Python/CRM_ERP_Reconciliation_Pipeline/`

2. Create and activate a virtual environment:

```bash
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

3. Create a `.env` file in the project root:

```env
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=<your password>
MYSQL_DATABASE=crm_erp_reconciliation
```

4. Run `sql/schema.sql` in MySQL Workbench

5. Generate the source data by running `notebooks/data_generation.ipynb`

6. Start the mock CRM API:

```bash
cd mock_api
uvicorn crm_api:app --reload
```

7. Run the pipeline:

```bash
cd etl
python main.py
```

---

## Future Enhancement Opportunities

- **Power BI dashboard** on top of `fact_reconciliation`
- **NBP API integration** for live exchange rates
- **Slack / email notifications** on pipeline failure or threshold breaches
- **Docker Compose** setup for MySQL + mock API + pipeline
