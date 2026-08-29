# transform.py,
# Cleans and reconciles the raw ERP and CRM data. Consists of 4 parts:
# validate_erp, normalize_currency, reconcile,
# and a main block that ties them together.

# PL: transform.py, Czysci i uzgadnia surowe dane ERP i CRM.
# Sklada sie z 4 czesci: validate_erp, normalize_currency, reconcile,
# oraz blok main spinajacy calosc.

import pandas as pd


def validate_erp(df: pd.DataFrame) -> tuple[pd.DataFrame, dict]:
    # Checks the 3 known problem types from data_generation.ipynb and
    # removes the bad rows. Returns the cleaned dataframe plus a dict of
    # counts, used later for the run_log entry.

    # PL: Sprawdza 3 znane typy problemow z data_generation.ipynb i usuwa
    # bledne wiersze. Zwraca oczyszczony dataframe oraz slownik zbalansowanych
    # zliczen, wykorzystywany pozniej we wpisie run_log.

    issues = {}

    # Negative amounts: an order should never have a negative value.
    # PL: Ujemne kwoty: zamowienie nigdy nie powinno miec ujemnej wartosci.
    negative_mask = df["amount"] < 0
    issues["negative_amount"] = int(negative_mask.sum())
    df = df[~negative_mask]


    # Missing customer_id: incomplete record, can't attribute the order.
    # PL: Brak customer_id: niekompletny rekord, nie mozna przypisac zamowienia.
    null_customer_mask = df["customer_id"].isna()
    issues["null_customer_id"] = int(null_customer_mask.sum())
    df = df[~null_customer_mask]


    # Duplicate order_id: the same order appearing more than once.
    # keep="first" marks every occurrence after the first as a duplicate.

    # PL: Zduplikowany order_id: to samo zamowienie wystepuje wiecej niz
    # raz. keep="first" oznacza kazde wystapienie po pierwszym jako duplikat.
    duplicate_mask = df.duplicated(subset="order_id", keep="first")
    issues["duplicate_order_id"] = int(duplicate_mask.sum())
    df = df[~duplicate_mask]

    issues["rows_flagged"] = sum(issues.values())

    return df.reset_index(drop=True), issues


# Static reference rates, approximate mid-market as of August 2026. A
# production version would call the NBP API instead of this fixed table.

# PL: Statyczna tabela kursow, przyblizone srednie rynkowe z sierpnia
# 2026. Wersja produkcyjna pobieralaby kursy z API NBP zamiast tej
# stalej tabeli.

EXCHANGE_RATES_TO_PLN = {
    "PLN": 1.00,
    "EUR": 4.32,
    "USD": 3.73,
}


def normalize_currency(df: pd.DataFrame, rate_table: dict = EXCHANGE_RATES_TO_PLN) -> pd.DataFrame:
    # Adds amount_pln: every row's amount converted to PLN, so CRM and
    # ERP amounts become comparable regardless of the original currency.
    # The original amount/currency columns are kept untouched alongside it.

    # PL: Dodaje amount_pln: kazda kwota przeliczona na PLN, dzieki czemu
    # kwoty CRM i ERP staja sie porownywalne niezaleznie od oryginalnej
    # waluty. Oryginalne kolumny amount/currency zostaja nietkniete obok niej.

    df = df.copy()
    df["amount_pln"] = df.apply(
        lambda row: round(row["amount"] * rate_table[row["currency"]], 2),
        axis=1,
    )
    return df


def reconcile(crm_df: pd.DataFrame, erp_df: pd.DataFrame, tolerance: float = 0.01) -> pd.DataFrame:
    # Expects inputs processed by normalize_currency (amount_pln present)
    # and validated erp_df. Runs 2 independent checks:
    #
    # Part A: Won CRM deal vs. linked ERP order -> MATCHED / AMOUNT_MISMATCH / CRM_ONLY.
    # Checks business state.
    #
    # Part B: Linked ERP order vs. full CRM list -> ERP_ONLY if deal_id doesn't exist.
    # Checks data integrity (a non-Won deal is different from a non-existent ID).
    #
    # PL: Zaklada dane po normalize_currency (obecne amount_pln)
    # i zweryfikowane erp_df. Wykonuje 2 niezalezne testy:
    #
    # Czesc A: Wygrany deal CRM vs powiazane zamowienie ERP -> MATCHED / AMOUNT_MISMATCH / CRM_ONLY.
    # Sprawdza stan biznesowy.
    #
    # Czesc B: Zamowienie ERP vs pelna lista CRM -> ERP_ONLY gdy deal_id nie istnieje.
    # Sprawdza integralnosc danych (deal nie-Wygrany to co innego niz brakujace ID).
    
    won_deals = crm_df[crm_df["stage"] == "Won"].copy()
    linked_orders = erp_df[erp_df["crm_deal_id"].notna()].copy()


    # outer join: "both" = a match on both sides, "left_only" = deal with
    # no order (CRM_ONLY), "right_only" = order not matched to a Won deal,
    # left unclassified here on purpose, resolved in Part B instead.
    # PL: outer join: "both" = dopasowanie po obu stronach, "left_only" =
    # deal bez zamowienia (CRM_ONLY), "right_only" = zamowienie
    # niedopasowane do zadnego wygranego deala, celowo nieklasyfikowane
    # tutaj, rozwiazywane w Czesci B.
    merged = won_deals.merge(
        linked_orders,
        left_on="deal_id",
        right_on="crm_deal_id",
        how="outer",
        suffixes=("_crm", "_erp"),
        indicator=True,
    )

    rows = []

    for _, row in merged.iterrows():
        if row["_merge"] == "left_only":
            rows.append({
                "reconciliation_key": row["deal_id"],
                "order_id": None,
                "deal_id": row["deal_id"],
                "erp_amount": None,
                "crm_amount": row["amount_pln_crm"],
                "variance_pct": None,
                "status": "CRM_ONLY",
            })
        elif row["_merge"] == "both":
            crm_amt = row["amount_pln_crm"]
            erp_amt = row["amount_pln_erp"]
            variance = abs(erp_amt - crm_amt) / crm_amt
            status = "MATCHED" if variance <= tolerance else "AMOUNT_MISMATCH"
            rows.append({
                "reconciliation_key": row["deal_id"],
                "order_id": row["order_id"],
                "deal_id": row["deal_id"],
                "erp_amount": erp_amt,
                "crm_amount": crm_amt,
                "variance_pct": round(variance * 100, 3),
                "status": status,
            })


    # Part B: linked orders whose crm_deal_id is not in the CRM deal list
    # at all (any stage), independent of the Won-only join above.

    # PL: Czesc B: powiazane zamowienia, ktorych crm_deal_id nie wystepuje
    # w liscie dealow CRM w ogole (zaden etap), niezaleznie od powyzszego
    # polaczenia ograniczonego do Won.
    all_deal_ids = set(crm_df["deal_id"])
    erp_only = linked_orders[~linked_orders["crm_deal_id"].isin(all_deal_ids)]

    for _, row in erp_only.iterrows():
        rows.append({
            "reconciliation_key": row["order_id"],
            "order_id": row["order_id"],
            "deal_id": row["crm_deal_id"],
            "erp_amount": row["amount_pln"],
            "crm_amount": None,
            "variance_pct": None,
            "status": "ERP_ONLY",
        })

    return pd.DataFrame(rows)


# Runs the full transform standalone: extract -> validate -> normalize ->
# reconcile, then prints what happened at each stage. extract.py is
# imported here, not at the top of the file, so transform.py stays usable
# as a plain module (by main.py later) without dragging in the HTTP call
# unless this file is actually run directly.

# PL: Uruchamia cala transformacje samodzielnie:
# extract -> validate -> normalize -> reconcile,
# i wypisuje co sie stalo na kazdym etapie. extract.py jest importowane tutaj,
# nie na gorze pliku, zeby transform.py pozostalo uzywalne jako zwykly modul (przez main.py pozniej)
# bez ciagniecia za soba wywolania HTTP, chyba ze ten plik jest uruchamiany bezposrednio.
if __name__ == "__main__":
    from extract import extract_crm, extract_erp

    erp_raw = extract_erp()
    erp_clean, issues = validate_erp(erp_raw)
    print(f"ERP validation: {len(erp_raw)} rows in, {len(erp_clean)} rows out")
    print(f"Issues found: {issues}")

    erp_pln = normalize_currency(erp_clean)
    crm_pln = normalize_currency(extract_crm())
    print(f"\nCRM deals: {len(crm_pln)}, ERP orders (clean): {len(erp_pln)}")

    result = reconcile(crm_pln, erp_pln)
    print(f"\nReconciliation result ({len(result)} rows total):")
    print(result["status"].value_counts())
