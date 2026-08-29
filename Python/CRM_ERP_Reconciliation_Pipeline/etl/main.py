# Main.py
#
# Orchestrates the full pipeline: extract -> transform -> load, with logging and retry.
#
# PL: Spina caly pipeline: extract -> transform -> load, z logowaniem i ponawianiem prob.

import logging
import os
from datetime import datetime

from tenacity import before_sleep_log, retry, stop_after_attempt, wait_exponential

from extract import extract_crm, extract_erp
from load import get_connection, load_fact_reconciliation, load_staging, log_run
from transform import normalize_currency, reconcile, validate_erp

LOG_PATH = "../logs/pipeline.log"
logger = logging.getLogger(__name__)


def setup_logging():
    # Writes to logs/pipeline.log AND the console at the same time (two
    # handlers), so a failed overnight run can still be diagnosed from
    # the file, without the console going completely silent during an
    # interactive run, which filename= alone would do.

    # PL: Zapisuje jednoczesnie do logs/pipeline.log ORAZ na konsole (dwa
    # handlery), zeby nieudany przebieg w nocy dalo sie zdiagnozowac z
    # pliku, a jednoczesnie konsola nie milczala calkowicie przy
    # uruchomieniu interaktywnym, co samo filename= by spowodowalo.
    os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        handlers=[
            logging.FileHandler(LOG_PATH),
            logging.StreamHandler(),
        ],
    )


# Retries fetch_crm_deals up to 3 times with exponential backoff before
# giving up. The only place in the project that reaches out over the
# network to a live service, so the only place that actually needs this
# kind of resilience, the mock API might just not be started yet.

# PL: Ponawia fetch_crm_deals do 3 razy z rosnacym opoznieniem (backoff)
# zanim odda blad dalej. Jedyne miejsce w projekcie, ktore laczy sie
# przez siec z zywym serwisem, wiec jedyne, ktore faktycznie potrzebuje
# takiej odpornosci, mock API moze po prostu jeszcze nie wystartowac.
@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10),
    before_sleep=before_sleep_log(logger, logging.WARNING),
)
def fetch_crm_deals(since: str | None = None):
    return extract_crm(since=since)


# One full run: extract both sources, clean, reconcile, and write
# everything to MySQL, with a run_log entry for each step. This is the
# same sequence the test block in load.py used to run manually, moved
# here so load.py can go back to being a plain module with no
# orchestration logic of its own. conn.close() sits in finally so the
# connection always gets released, even if a step above it fails.

# PL: Jeden pelny przebieg: ekstrakcja obu zrodel, czyszczenie,
# uzgadnianie, i zapis wszystkiego do MySQL, z wpisem run_log na kazdy
# krok. To ta sama sekwencja, ktora wczesniej recznie uruchamial blok
# testowy w load.py, przeniesiona tutaj, zeby load.py mogl wrocic do
# bycia zwyklym modulem bez wlasnej logiki orkiestracji. conn.close()
# siedzi w finally, zeby polaczenie zawsze zostalo zwolnione, nawet gdy
# ktorys krok wyzej zawiedzie.
def run_pipeline(since: str | None = None) -> str:
    batch_id = datetime.now().strftime("%Y%m%d-%H%M%S")
    logger.info(f"Starting batch {batch_id}")

    erp_raw = extract_erp()
    crm_raw = fetch_crm_deals(since=since)

    erp_clean, issues = validate_erp(erp_raw)
    erp_pln = normalize_currency(erp_clean)
    crm_pln = normalize_currency(crm_raw)

    result = reconcile(crm_pln, erp_pln)

    conn = get_connection()
    try:
        staged = load_staging(conn, erp_raw, crm_raw)
        log_run(conn, batch_id, "erp_extract", len(erp_raw), issues["rows_flagged"], "success")
        log_run(conn, batch_id, "crm_extract", len(crm_raw), 0, "success")

        fact_rows = load_fact_reconciliation(conn, result, batch_id)
        log_run(conn, batch_id, "reconcile_load", fact_rows, 0, "success")
    except Exception:
        logger.exception(f"Batch {batch_id} failed during load")
        raise
    finally:
        conn.close()

    logger.info(
        f"Batch {batch_id} complete: {staged['erp_rows']} ERP rows staged, "
        f"{staged['crm_rows']} CRM rows staged, {fact_rows} fact rows upserted"
    )
    return batch_id


def _safe_run_pipeline():
    # schedule stops calling a job again after it raises once. Catching
    # here (run_pipeline already logged the full traceback via
    # logger.exception) keeps tomorrow's 02:00 run scheduled even if
    # tonight's run failed. Used only for the scheduled call below, the
    # immediate test run further down is left unwrapped on purpose, so
    # failures surface directly while testing instead of being swallowed.

    # PL: schedule przestaje wywolywac zadanie ponownie, gdy raz rzuci
    # wyjatkiem. Zlapanie go tutaj (run_pipeline juz zalogowal pelny
    # traceback przez logger.exception) utrzymuje jutrzejszy przebieg o
    # 02:00 zaplanowany, nawet jesli dzisiejszy sie nie udal. Uzywane
    # tylko dla zaplanowanego wywolania ponizej, natychmiastowe
    # uruchomienie testowe dalej celowo zostaje nieowiniete, zeby bledy
    # ujawnialy sie wprost podczas testowania, zamiast zostac polkniete.
    try:
        run_pipeline()
    except Exception:
        pass


# setup_logging() first, then one immediate run so testing does not mean
# waiting until 02:00, then hand control to the daily schedule. 02:00 is
# after the ERP export and CRM data for the day are expected to be
# settled. schedule.run_pending() only fires jobs that are actually due,
# the 60s sleep is just how often it bothers to check.

# PL: Najpierw setup_logging(), potem jedno natychmiastowe uruchomienie,
# zeby test nie oznaczal czekania do 02:00, a nastepnie oddanie
# sterowania harmonogramowi dziennemu. 02:00 to pora, gdy eksport ERP i
# dane CRM za dany dzien powinny byc juz ustalone. schedule.run_pending()
# uruchamia tylko zadania, ktore faktycznie sa juz na czasie, sen 60s to
# tylko jak czesto sprawdza.
if __name__ == "__main__":
    import time

    import schedule

    setup_logging()

    run_pipeline()

    schedule.every().day.at("02:00").do(_safe_run_pipeline)
    logger.info("Scheduler started, next run at 02:00 daily")

    while True:
        schedule.run_pending()
        time.sleep(60)
