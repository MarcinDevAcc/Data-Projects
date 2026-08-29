# ===========================================================================
# Extract
# Pulls raw data from both sources: the ERP CSV export on disk, and the
# mock CRM API over HTTP. No cleaning or validation here, that happens in
# transform.py. Just read/fetch and hand back as DataFrames.

# PL: Ekstrakcja. Pobiera surowe dane z obu zrodel: eksportu CSV z ERP z
# dysku oraz mockowego API CRM przez HTTP. Zadnego czyszczenia ani
# walidacji tutaj, to dzieje sie w transform.py. Tylko odczyt/pobranie i
# zwrocenie jako DataFrame.
# ===========================================================================

import pandas as pd
import requests

ERP_CSV_PATH = "../data/raw/erp_orders_export.csv"
CRM_API_URL = "http://127.0.0.1:8000/deals"


def extract_erp(path: str = ERP_CSV_PATH) -> pd.DataFrame:

    # Plain CSV read, the "nightly export" landing on disk.

    # PL: Zwykly odczyt CSV, "nocny eksport" ladujacy na dysku.
    return pd.read_csv(path)


def extract_crm(since: str | None = None, base_url: str = CRM_API_URL) -> pd.DataFrame:
    # since=None pulls every deal (full load). A date string like
    # "2025-11-01" pulls only deals closed on or after that date
    # (incremental load), the same parameter the mock API expects.

    # PL: since=None pobiera wszystkie deale (pelny load). Data w
    # formacie "2025-11-01" pobiera tylko deale zamkniete od tej daty
    # (incremental load), zgodnie z parametrem, jaki przyjmuje mock API.
    params = {"since": since} if since else {}
    response = requests.get(base_url, params=params)
    response.raise_for_status()  # raises an exception on 4xx/5xx responses
    return pd.DataFrame(response.json())


# Lets you run "python extract.py" directly to sanity-check both sources
# without writing a separate test script.

# PL: Pozwala odpalic "python extract.py" bezposrednio, zeby sprawdzic
# oba zrodla bez pisania osobnego skryptu testowego.
if __name__ == "__main__":
    erp_df = extract_erp()
    print("ERP orders:", erp_df.shape)
    print(erp_df.head())

    crm_df = extract_crm()
    print("\nCRM deals:", crm_df.shape)
    print(crm_df.head())
