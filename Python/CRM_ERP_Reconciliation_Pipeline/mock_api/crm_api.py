# Mock CRM API
# Serves the CRM deals seed data over HTTP, 
# serves as a substitute for a real CRM's REST API.

# PL: Symulowane API CRM.
# Wysyła dane CRM przez HTTP, jako zamiennik prawdziwego API CRM.

import json
from datetime import date
from pathlib import Path

from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Mock CRM API")


# Path to the seed file generated in notebooks/data_generation.ipynb.
# PL: Sciezka do pliku seed wygenerowanego w notebooks/data_generation.ipynb.
SEED_PATH = Path(__file__).parent.parent / "data" / "raw" / "crm_deals_seed.json"


# Loaded once at startup, kept in memory for every request that follows.
# PL: Wczytywane raz przy starcie, trzymane w pamieci dla kazdego zadania.
with open(SEED_PATH, encoding="utf-8") as f:
    ALL_DEALS = json.load(f)


# Shape of one deal in the response. FastAPI uses this to validate
# outgoing data and to build the interactive /docs page automatically.

# PL: Ksztalt jednego deala w odpowiedzi. FastAPI uzywa tego do walidacji
# wychodzacych danych i do budowania strony /docs automatycznie.

class Deal(BaseModel):
    deal_id: str
    account_id: str
    amount: float
    currency: str
    close_date: date
    sales_rep: str
    country_code: str
    stage: str


# since is optional: with no value, every deal is returned. 
# FastAPI parses the query string into a real date object and validates it, 
# an invalid format (e.g. "yesterday") is rejected automatically
# with a 422 response, before this function even runs.

# PL: since jest opcjonalne: bez wartosci zwracane sa wszystkie deale.
# FastAPI parsuje parametr zapytania do prawdziwego obiektu date i go waliduje,
# niepoprawny format jest automatycznie odrzucany odpowiedzia 422, 
# zanim ta funkcja w ogole sie uruchomi.

@app.get("/deals", response_model=list[Deal])
def get_deals(since: date | None = None):
    if since is None:
        return ALL_DEALS
    return [
        deal for deal in ALL_DEALS
        if date.fromisoformat(deal["close_date"]) >= since
    ]
