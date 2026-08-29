# CRM-ERP Reconciliation Pipeline - Python ETL Project

## Overview

Python ETL pipeline that reconciles sales data between two systems that rarely agree in real companies: a CRM (what sales recorded) and an ERP (what finance actually invoiced). The pipeline extracts from two independent sources (a CSV export and a live REST API), validates and cleans the data, reconciles CRM deals against ERP orders, and loads the result into MySQL with a full audit trail.

> **Note**: All data in this project is synthetically generated using Python (Faker). It does not represent any real company, supplier, or business operation.

> **A note on the code comments**: every comment in the source code and SQL files is bilingual, an English line followed by a Polish translation (prefixed `# PL:`), written that way for personal learning purposes while building the project. This README is English-only.

---

## Dataset Scope

### Generated Data Profile
- **200 CRM deals**, stage mix: Won 131, Open 34, Lost 35
- **274 ERP orders**, simulating a nightly export
- **3 currencies**: PLN, EUR, USD
- **5 countries**: Poland, Germany, France, Spain, Italy
- **Time period**: 2025

### Intentional Discrepancies
Injected on purpose during data generation, so the reconciliation logic has real, verifiable cases to detect rather than clean data with nothing to find:

| Category | Design Target | Description |
|---|---|---|
| MATCHED | ~70% of Won deals | ERP order exists, amount within 1% of the CRM deal |
| AMOUNT_MISMATCH | ~15% of Won deals | ERP order exists, amount off by 5-25% |
| CRM_ONLY | ~15% of Won deals | Deal won in CRM, never invoiced in ERP |
| ERP_ONLY | 12 orders | ERP order references a `deal_id` that does not exist in CRM at all |
| Organic orders | 150 orders | No CRM link at all, outside reconciliation scope |
| Data quality issues | 8 rows | 3 negative amounts, 3 missing `customer_id`, 2 duplicate rows |

---

## Key Features

### Multi-Source Extraction
- CSV file (simulated nightly ERP export), read with pandas
- REST API (mock CRM built with FastAPI), pulled with `requests`, supports incremental extraction via a `?since=<date>` query parameter

### Data Validation
- Detects negative amounts, missing customer IDs, and duplicate order IDs before they reach the reconciliation logic
- Returns both the cleaned data and a count of what was flagged, for the audit log

### Currency Normalization
- Converts PLN/EUR/USD to a common currency (PLN) via a static reference rate table before any amount is compared

### Reconciliation Logic
- Classifies every CRM deal / ERP order pair into one of four outcomes (see table above)
- Two independent checks: a business-state comparison (Won deals vs. their orders) and a data-integrity comparison (order references vs. the full CRM deal list), because a broken reference and a deal that simply is not Won yet are not the same kind of problem

### Incremental & Idempotent Loading
- Staging tables are truncated and reloaded every run, an exact landing copy of the raw extract, bad rows included
- The fact table is upserted with `INSERT ... ON DUPLICATE KEY UPDATE`, safe to re-run without duplicating rows

### Automation & Resilience
- Retry with exponential backoff (`tenacity`) on the CRM API call
- Daily scheduling (`schedule`), 02:00
- Logging to file and console, with a full audit trail in a dedicated `run_log` table

---

## ETL & SQL Techniques Demonstrated

| Technique | Where Applied |
|---|---|
| Multi-source extraction (file + REST API) | `extract.py` |
| Data validation & cleaning | `validate_erp()` in `transform.py` |
| Currency normalization | `normalize_currency()` in `transform.py` |
| Outer-join reconciliation logic | `reconcile()` in `transform.py` |
| Upsert (`ON DUPLICATE KEY UPDATE`) | `load_fact_reconciliation()` in `load.py` |
| Staging tables (truncate-and-load) | `load_staging()` in `load.py`, `schema.sql` |
| Incremental extraction (`since` parameter) | `crm_api.py`, `extract_crm()` |
| Retry with exponential backoff | `tenacity`, `fetch_crm_deals()` in `main.py` |
| Scheduled automation | `schedule`, `main.py` |
| Audit logging | `run_log` table, `log_run()` in `load.py` |

---

## Data Model

Four MySQL tables (`sql/schema.sql`):

| Table | Type | Purpose |
|---|---|---|
| `stg_erp_orders` | Staging | Raw ERP export, truncated and reloaded every run |
| `stg_crm_deals` | Staging | Raw CRM deals, truncated and reloaded every run |
| `fact_reconciliation` | Fact | Clean reconciliation result, upserted on `reconciliation_key` |
| `run_log` | Audit | One row per pipeline step per batch |

---

## Example Run Result

Actual output from a full pipeline run against the generated dataset:

```
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

1. **Data quality issues cascade into reconciliation outcomes.** 4 of the 8 rows flagged by validation belonged to orders linked to Won deals. Once removed as bad data, those deals correctly shifted from MATCHED/AMOUNT_MISMATCH to CRM_ONLY, moving the final result from the as-designed 91/19/21 split to the actual 89/17/25. The pipeline derives this on its own; it is not a static, pre-computed expectation.
2. **32% of Won-deal outcomes are not a clean match** (AMOUNT_MISMATCH + CRM_ONLY combined, 42 of 131), the kind of gap a Control Management & Risk or Finance team would want surfaced automatically rather than discovered at month-end close.
3. **12 ERP orders reference a CRM deal ID that does not exist at all**, a data-integrity problem distinct from a business-status mismatch, and checked independently in the reconciliation logic for exactly that reason.

---

## Business Value

- **Revenue leakage detection** - flags deals marked Won in CRM that were never actually invoiced
- **Data integrity monitoring** - surfaces broken references between systems before they cause downstream reporting errors
- **Audit-ready automation** - every run is logged with row counts and status per step, replacing a manual, ad-hoc reconciliation process
- **Reusable pattern** - the same extract/validate/reconcile/load structure generalizes to any two systems that are supposed to agree but do not (e.g. billing vs. usage, inventory vs. sales)

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

```
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
2. Create and activate a virtual environment, then install dependencies:
   ```
   python -m venv venv
   venv\Scripts\activate
   pip install -r requirements.txt
   ```
3. Create a `.env` file in the project root:
   ```
   MYSQL_HOST=localhost
   MYSQL_PORT=3306
   MYSQL_USER=root
   MYSQL_PASSWORD=<your password>
   MYSQL_DATABASE=crm_erp_reconciliation
   ```
4. Run `sql/schema.sql` in MySQL Workbench to create the database and all four tables
5. Generate the source data: run `notebooks/data_generation.ipynb` end to end
6. Start the mock CRM API in its own terminal:
   ```
   cd mock_api
   uvicorn crm_api:app --reload
   ```
7. Run the pipeline:
   ```
   cd etl
   python main.py
   ```

---

## Future Enhancement Opportunities

- **Power BI dashboard** on top of `fact_reconciliation`, for a non-technical view of the reconciliation backlog
- **NBP API integration** for live exchange rates instead of the static rate table
- **Slack/email notification** on pipeline failure or when CRM_ONLY volume crosses a threshold
- **Docker Compose** setup (MySQL + mock API + pipeline) for one-command reproducibility
