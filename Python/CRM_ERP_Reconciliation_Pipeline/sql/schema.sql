# CRM-ERP Reconciliation Pipeline - Database Schema (MySQL 8.0)
# Builds the database, 2 staging tables (raw data), 1 fact table (clean
# result), 1 log table (run history). Safe to re-run: everything is
# dropped and recreated each time.
#
# PL: Schemat bazy (MySQL 8.0). Tworzy baze, 2 tabele staging (surowe
# dane), 1 tabele faktow (czysty wynik), 1 tabele logow (historia
# uruchomien). Bezpieczny do wielokrotnego uruchamiania.

# IF NOT EXISTS: safe to re-run. utf8mb4: full character support
# (Polish diacritics included). COLLATE: text sort/compare rule.
#
# PL: IF NOT EXISTS = bezpieczne ponowne uruchomienie. utf8mb4 = pelna
# obsluga znakow, w tym polskich. COLLATE = regula sortowania tekstu.
CREATE DATABASE IF NOT EXISTS crm_erp_reconciliation
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

# Every command below applies to this database.
# PL: Kazde kolejne zapytanie dotyczy tej bazy.
USE crm_erp_reconciliation;


# Staging Tables
# Raw landing tables, wiped (TRUNCATE) and reloaded every run. No
# constraints on purpose: bad data (nulls, duplicates, negative amounts)
# must be able to land here as-is, so transform.py has something real to
# catch. DECIMAL(12,2) is used for money instead of FLOAT: exact decimal
# math, no rounding drift when comparing two amounts.
#
# PL: Surowe tabele ladowania, czyszczone (TRUNCATE) i wypelniane od nowa
# przy kazdym uruchomieniu. Celowo bez ograniczen: zle dane (NULL,
# duplikaty, ujemne kwoty) musza tu trafic, zeby transform.py mial co
# wykryc. DECIMAL(12,2) zamiast FLOAT: dokladna matematyka na kwotach,
# bez bledow zaokraglen przy porownywaniu.


# Mirrors the ERP CSV export, one row per order.
# PL: Odzwierciedla eksport CSV z ERP, jeden wiersz na zamowienie.
DROP TABLE IF EXISTS stg_erp_orders;
CREATE TABLE stg_erp_orders (
    order_id        VARCHAR(20),
    crm_deal_id     VARCHAR(20),
    customer_id     VARCHAR(20),
    sku             VARCHAR(20),
    quantity        INT,
    unit_price      DECIMAL(12, 2),
    currency        VARCHAR(3),
    order_date      DATE,
    invoice_date    DATE,
    country_code    VARCHAR(2),
    amount          DECIMAL(12, 2)
);

# Mirrors the CRM JSON feed, one row per deal.
# PL: Odzwierciedla dane JSON z CRM, jeden wiersz na deal.
DROP TABLE IF EXISTS stg_crm_deals;
CREATE TABLE stg_crm_deals (
    deal_id         VARCHAR(20),
    account_id      VARCHAR(20),
    amount          DECIMAL(12, 2),
    currency        VARCHAR(3),
    close_date      DATE,
    sales_rep       VARCHAR(100),
    country_code    VARCHAR(2),
    stage           VARCHAR(20)
);


# fact_reconciliation
# Clean result, written via upsert (insert new / update existing, so
# re-runs never duplicate rows) using ON DUPLICATE KEY UPDATE.
#
# reconciliation_key = deal_id if the row has one, otherwise order_id.
# Needed because CRM_ONLY rows have no order_id and ERP_ONLY rows have no
# deal_id, upsert requires one single non-null key.
#
# status is an ENUM: only the 4 listed values are allowed, MySQL rejects
# anything else, a guard against typos.
#
# PL: Czysty wynik, zapisywany przez upsert (wstaw nowy / zaktualizuj
# istniejacy, zeby ponowne uruchomienie nie duplikowalo wierszy), przez
# ON DUPLICATE KEY UPDATE.
#
# reconciliation_key = deal_id, jesli wiersz go ma, w przeciwnym razie
# order_id. Potrzebne, bo wiersze CRM_ONLY nie maja order_id, a ERP_ONLY
# nie maja deal_id, upsert wymaga jednego niepustego klucza.
#
# status to ENUM: dozwolone tylko 4 wymienione wartosci, MySQL odrzuci
# cokolwiek innego, zabezpieczenie przed literowkami.


DROP TABLE IF EXISTS fact_reconciliation;
CREATE TABLE fact_reconciliation (
    reconciliation_key  VARCHAR(20) PRIMARY KEY,
    order_id            VARCHAR(20),
    deal_id             VARCHAR(20),
    erp_amount          DECIMAL(12, 2),
    crm_amount          DECIMAL(12, 2),
    variance_pct        DECIMAL(6, 3),
    status              ENUM('MATCHED', 'AMOUNT_MISMATCH', 'CRM_ONLY', 'ERP_ONLY') NOT NULL,
    batch_id            VARCHAR(20) NOT NULL,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


# run_log
# Audit trail: one row per pipeline step per batch (e.g. one for the ERP
# extract, one for the CRM extract), not one row per batch overall. That
# is why batch_id repeats on purpose and cannot be the primary key,
# log_id (AUTO_INCREMENT = auto-numbered) is used instead. INDEX on
# batch_id keeps later lookups fast as the table grows.
#
# PL: Slad audytowy: jeden wiersz na kazdy krok pipelineu w ramach
# batcha (np. osobny dla ekstrakcji ERP, osobny dla CRM), nie jeden na
# caly batch. Dlatego batch_id celowo sie powtarza i nie moze byc
# kluczem glownym, uzywany jest log_id (AUTO_INCREMENT = auto-numerowanie).
# INDEX na batch_id przyspiesza pozniejsze wyszukiwanie.


DROP TABLE IF EXISTS run_log;
CREATE TABLE run_log (
    log_id          INT AUTO_INCREMENT PRIMARY KEY,
    batch_id        VARCHAR(20) NOT NULL,
    run_timestamp   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    source          VARCHAR(20) NOT NULL,
    rows_extracted  INT DEFAULT 0,
    rows_flagged    INT DEFAULT 0,
    status          VARCHAR(20) NOT NULL,
    INDEX idx_batch_id (batch_id)
);
