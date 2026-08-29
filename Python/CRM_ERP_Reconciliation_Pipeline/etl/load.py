# Load.py
# Writes cleaned/reconciled data to MySQL.
# PL: Zapis do MySQL. Zapisuje oczyszczone/uzgodnione dane do MySQL.

import os

import mysql.connector
import pandas as pd
from dotenv import load_dotenv

load_dotenv()

# Explicit column order for staging inserts, matches schema.sql exactly.
# Selecting by name before insert guards against a future upstream
# reorder silently shifting values into the wrong column.

# PL: Jawna kolejnosc kolumn dla inserta do staging, zgodna ze schema.sql.
# Wybor po nazwie przed insertem chroni przed przyszla zmiana kolejnosci
# w zrodle, ktora po cichu przesunelaby wartosci do zlej kolumny.
ERP_COLUMNS = [
    "order_id", "crm_deal_id", "customer_id", "sku", "quantity",
    "unit_price", "currency", "order_date", "invoice_date",
    "country_code", "amount",
]
CRM_COLUMNS = [
    "deal_id", "account_id", "amount", "currency", "close_date",
    "sales_rep", "country_code", "stage",
]

# Same idea as ERP_COLUMNS/CRM_COLUMNS above: names the exact columns
# going into fact_reconciliation, in order, matching schema.sql.

# PL: Ta sama idea co przy ERP_COLUMNS/CRM_COLUMNS: nazywa dokladne
# kolumny wchodzace do fact_reconciliation, w kolejnosci zgodnej ze schema.sql.
FACT_COLUMNS = [
    "reconciliation_key", "order_id", "deal_id", "erp_amount",
    "crm_amount", "variance_pct", "status", "batch_id",
]


def _none_safe_rows(df: pd.DataFrame) -> list[tuple]:
    # Converts a dataframe to a list of tuples with every NaN/NaT
    # replaced by a real Python None. DataFrame.where(pd.notnull(df),
    # None) looks like it should do this, but pandas silently keeps NaN
    # in numeric-dtype columns even after that call. mysql-connector's
    # batched executemany() then renders that leftover NaN as the bare
    # word "nan" in the SQL text, not a valid number, not a quoted
    # string, and MySQL reads it as a column name and rejects it.

    # PL: Zamienia dataframe na liste krotek, z kazdym NaN/NaT zamienionym
    # na prawdziwe Python None. DataFrame.where(pd.notnull(df), None)
    # wyglada jakby to robilo, ale pandas po cichu zostawia NaN w
    # kolumnach o typie liczbowym nawet po tym wywolaniu. Wsadowy
    # executemany() sterownika mysql-connector renderuje potem ten
    # pozostaly NaN jako gole slowo "nan" w tekscie SQL, nie jest to ani
    # poprawna liczba, ani cytowany string, wiec MySQL odczytuje to jako
    # nazwe kolumny i odrzuca.
    return [
        tuple(None if pd.isna(v) else v for v in row)
        for row in df.itertuples(index=False, name=None)
    ]


def get_connection():
    # Opens a MySQL connection using credentials from .env
    # PL: Otwiera polaczenie MySQL z danych logowania w .env
    return mysql.connector.connect(
        host=os.getenv("MYSQL_HOST"),
        port=os.getenv("MYSQL_PORT"),
        user=os.getenv("MYSQL_USER"),
        password=os.getenv("MYSQL_PASSWORD"),
        database=os.getenv("MYSQL_DATABASE"),
    )


def load_staging(conn, erp_df: pd.DataFrame, crm_df: pd.DataFrame) -> dict:
    # Loads the RAW extract (before validate_erp) into staging, exactly
    # as agreed in schema.sql: staging is a landing zone, bad rows must
    # land here too. TRUNCATE first, so every run fully replaces the
    # previous one instead of accumulating rows across batches.

    # PL: Laduje SUROWY extract (przed validate_erp) do staging, zgodnie
    # z ustaleniem w schema.sql: staging to strefa ladowania, bledne
    # wiersze tez musza tu trafic. Najpierw TRUNCATE, zeby kazdy przebieg
    # w calosci zastapil poprzedni zamiast gromadzic wiersze z wielu batchy.
    cursor = conn.cursor()

    cursor.execute("TRUNCATE TABLE stg_erp_orders")
    cursor.execute("TRUNCATE TABLE stg_crm_deals")

    # NaN -> None: pandas' missing-value marker means nothing to the
    # MySQL driver, only a real None becomes SQL NULL.

    # PL: NaN -> None: brak wartosci w pandas nic nie znaczy dla
    # sterownika MySQL, dopiero prawdziwe None zamienia sie na SQL NULL.
    erp_rows = _none_safe_rows(erp_df[ERP_COLUMNS])
    crm_rows = _none_safe_rows(crm_df[CRM_COLUMNS])

    erp_insert = f"""
        INSERT INTO stg_erp_orders ({", ".join(ERP_COLUMNS)})
        VALUES ({", ".join(["%s"] * len(ERP_COLUMNS))})
    """
    crm_insert = f"""
        INSERT INTO stg_crm_deals ({", ".join(CRM_COLUMNS)})
        VALUES ({", ".join(["%s"] * len(CRM_COLUMNS))})
    """

    cursor.executemany(erp_insert, erp_rows)
    cursor.executemany(crm_insert, crm_rows)
    conn.commit()
    cursor.close()

    # Returned for the run_log entries main.py will write later, one per source.
    # PL: Zwracane na potrzeby wpisow run_log, ktore main.py zapisze pozniej, jedno na zrodlo.
    return {"erp_rows": len(erp_rows), "crm_rows": len(crm_rows)}


def load_fact_reconciliation(conn, result_df: pd.DataFrame, batch_id: str) -> int:
    # Upserts the reconcile() output into fact_reconciliation.
    # ON DUPLICATE KEY UPDATE on reconciliation_key: re-running the
    # pipeline updates existing rows instead of piling up duplicates,
    # the whole reason that column exists (see schema.sql).

    # PL: Robi upsert wyniku reconcile() do fact_reconciliation.
    # ON DUPLICATE KEY UPDATE po reconciliation_key: ponowne uruchomienie
    # pipeline'u aktualizuje istniejace wiersze zamiast je duplikowac, to
    # caly powod istnienia tej kolumny (patrz schema.sql).
    df = result_df.copy()
    df["batch_id"] = batch_id

    rows = _none_safe_rows(df[FACT_COLUMNS])

    insert_sql = f"""
        INSERT INTO fact_reconciliation ({", ".join(FACT_COLUMNS)})
        VALUES ({", ".join(["%s"] * len(FACT_COLUMNS))})
        ON DUPLICATE KEY UPDATE
            order_id = VALUES(order_id),
            deal_id = VALUES(deal_id),
            erp_amount = VALUES(erp_amount),
            crm_amount = VALUES(crm_amount),
            variance_pct = VALUES(variance_pct),
            status = VALUES(status),
            batch_id = VALUES(batch_id)
    """

    cursor = conn.cursor()
    cursor.executemany(insert_sql, rows)
    conn.commit()
    cursor.close()

    return len(rows)


def log_run(conn, batch_id: str, source: str, rows_extracted: int, rows_flagged: int, status: str) -> None:
    # One insert per pipeline step, called multiple times from the main
    # block below (once for the ERP extract, once for CRM, once for the
    # fact load). log_id auto-increments; batch_id repeats on purpose,
    # exactly as designed in schema.sql.

    # PL: Jeden insert na krok pipeline'u, wywolywany wielokrotnie w bloku
    # main ponizej (raz dla ekstrakcji ERP, raz dla CRM, raz dla
    # zaladowania faktow). log_id auto-inkrementuje sie; batch_id celowo
    # sie powtarza, zgodnie z projektem w schema.sql.
    insert_sql = """
        INSERT INTO run_log (batch_id, source, rows_extracted, rows_flagged, status)
        VALUES (%s, %s, %s, %s, %s)
    """
    cursor = conn.cursor()
    cursor.execute(insert_sql, (batch_id, source, rows_extracted, rows_flagged, status))
    conn.commit()
    cursor.close()


# Runs the whole pipeline once, end to end, and reads the result back
# from MySQL to confirm it actually landed. extract.py/transform.py are
# imported here, not at the top of the file, for the same reason as in
# transform.py: this file stays a plain, importable module unless run
# directly.

# PL: Uruchamia caly pipeline raz, od poczatku do konca, i odczytuje
# wynik z powrotem z MySQL, zeby potwierdzic ze faktycznie tam wyladowal.
# extract.py/transform.py sa importowane tutaj, nie na gorze pliku, z
# tego samego powodu co w transform.py: ten plik pozostaje zwyklym,
# importowalnym modulem, chyba ze jest uruchamiany bezposrednio.
if __name__ == "__main__":
    from datetime import datetime

    from extract import extract_crm, extract_erp
    from transform import normalize_currency, reconcile, validate_erp

    batch_id = datetime.now().strftime("%Y%m%d-%H%M%S")

    erp_raw = extract_erp()
    crm_raw = extract_crm()

    erp_clean, issues = validate_erp(erp_raw)
    erp_pln = normalize_currency(erp_clean)
    crm_pln = normalize_currency(crm_raw)

    result = reconcile(crm_pln, erp_pln)

    conn = get_connection()

    staged = load_staging(conn, erp_raw, crm_raw)
    log_run(conn, batch_id, "erp_extract", len(erp_raw), issues["rows_flagged"], "success")
    log_run(conn, batch_id, "crm_extract", len(crm_raw), 0, "success")

    fact_rows = load_fact_reconciliation(conn, result, batch_id)
    log_run(conn, batch_id, "reconcile_load", fact_rows, 0, "success")

    print(f"Batch {batch_id} complete: {staged['erp_rows']} ERP rows staged, "
          f"{staged['crm_rows']} CRM rows staged, {fact_rows} fact rows upserted")

    # Read back from MySQL, not from the DataFrame still in memory, the
    # point is to confirm what is actually sitting in the database.

    # PL: Odczyt z powrotem z MySQL, nie z DataFrame wciaz w pamieci,
    # chodzi o potwierdzenie tego, co faktycznie siedzi w bazie danych.
    cursor = conn.cursor()
    cursor.execute("SELECT status, COUNT(*) FROM fact_reconciliation GROUP BY status")
    print("\nfact_reconciliation, grouped by status:")
    for status, count in cursor.fetchall():
        print(f"  {status}: {count}")
    cursor.close()
    conn.close()
