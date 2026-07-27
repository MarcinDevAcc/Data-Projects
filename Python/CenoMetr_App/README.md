# **CenoMetr — Apartment Price Prediction**

## **Overview**
**CenoMetr** is a predictive system for estimating apartment prices based on up‑to‑date listing data.  
The project combines web scraping, feature engineering, and machine learning models to deliver fast, data-driven price estimates.

**Project Goal**
Build a repeatable end‑to‑end pipeline enabling:
- prediction of total apartment price and price per square meter using listing data (Otodom),  
- analysis of how location and property features influence value,  
- a practical tool supporting investment and operational decision‑making.

---

## **Data Scope & Key Challenges**
**Data Source**  
- Listing data from Otodom (largest Polish real‑estate portal), covering 20 major Polish cities.

**Key Fields**  
- `price`, `area_m2`, `rooms`, `floor`, `district`, `city`, `region`.

**Main Data Quality Challenges**
- **Listing vs transaction prices** — listings tend to be inflated; differences may reach several percent.  
- **Missing & inconsistent fields** — incomplete entries, inconsistent location formats.  
- **Duplicates & outliers** — repeated listings, extreme values in price or area.  
- **Regional variability** — strong differences between local markets require spatial context.

---

## **Architecture & Pipeline (Summary)**

### **Processing Stages**

1. **Data Acquisition**  
   - Web scraping using **Selenium** + **geckodriver** collected listings across 20 Polish cities. *The scraping module itself is not included in this public repository, out of respect for the target site's terms of service — the data it produced (`otodom_housing_pages.csv`, `otodom_housing_pages_clean.csv`) is provided directly.*

2. **Initial Cleaning**  
   - Removing duplicates, standardizing formats (price, area, date), basic missing‑value filtering.

3. **Data Cleaning & Deduplication (Python)**  
   - Dropping helper columns, filtering missing district/room values, removing exact duplicate listings, and filtering implausible area values; output saved as `otodom_housing_pages_model_ready.csv` (`Preliminary_cleaning.py`).

4. **Feature Engineering**  
   - Encoding categorical variables (district, city, region); grouping low-sample districts (<50 listings) into a shared "other" category to reduce sparsity. Price per m² is computed as a derived output alongside the predicted total price, not used as a model input.

5. **Modeling**  
   - Random Forest, Decision Tree, and HistGradientBoosting compared, with and without district-level features; final choice: **Random Forest** with hyperparameter tuning, cross‑validation, and test‑set evaluation, scoped to the mainstream market (≤3M PLN, ≤400 m²).

6. **Model Serialization & Deployment**  
   - Saving the final model as `random_forest_final_<timestamp>.pkl`; CLI prediction module loads the model and returns price + price per m². *(The trained model file is not included in this repository — see below.)*

### **Key Files**
- `otodom_housing_pages_clean.csv` → `Preliminary_cleaning.py` → `otodom_housing_pages_model_ready.csv`  
- `Preparing_Model.ipynb`  
- `random_forest_final_<timestamp>.pkl` *(generated locally — not included in this repository, ~367 MB)*  
- `Prediction.py`, `Prediction.bat`, `City_Data.py`

---

## **Technologies & Tools**
**Language & Environment**
- **Python 3.10+**, Jupyter Notebook / VS Code, virtual environment `venv`.

**Libraries & Tools**
- **pandas**, **numpy** — data processing  
- **scikit‑learn** — ML models (Random Forest, HistGradientBoosting, Decision Tree), validation, tuning  
- **selenium** + **geckodriver** — web scraping (data collection module not included in this repo — see Data Acquisition above)  
- **joblib** — model serialization (`.pkl`)  
- **matplotlib**, **seaborn** — visualizations and reports

---

## **Modeling Methodology & Validation**
**Practices Used**
- Train / validation / test split.  
- Cross‑validation for stable performance estimates.  
- Outlier handling (filters, transformations, optional log‑price).  
- Hyperparameter tuning (grid/random search) for Random Forest.  
- Model report generation and final `.pkl` export.

---

## **Key Results & Insights**
**Technical Results**
- Final model: **Random Forest**, saved as `random_forest_final.pkl`.  
- Predicts **total price** and **price per m²** at city/district level using listing features.

**Business Insights**
- **Instant price estimates**: enables quick valuation of listings using current market data.  
- **Investment support**: feature analysis helps evaluate offer attractiveness.  
- **Development recommendations**: integrate transaction data, automate ETL, build API or BI dashboard.

---

## **How to Run (Summary)**
**Requirements**  
All setup instructions are provided in `INSTRUCTION.md`. Note that the trained model is not shipped with this repository — Part 2 of the guide trains a fresh copy locally.

---

**Note**  
Cleaning was originally performed manually in Excel/Power Query; this step has since been replaced with a fully automated Python script (`Preliminary_cleaning.py`) for full reproducibility.

---

## **Repository Structure (Summary)**
```
CenoMetr_App/
├─ CenoMetr/
│   ├─ 1._Webscraping_Otodom/
│   │   ├─ requirements.txt
│   │   ├─ otodom_housing_pages.csv
│   │   └─ otodom_housing_pages_clean.csv
│   │
│   ├─ 2._Training_and_Testing_Models/
│   │   ├─ Data_Cleaning/
│   │   │   ├─ Preliminary_cleaning.py
│   │   │   ├─ otodom_housing_pages_clean.csv
│   │   │   └─ otodom_housing_pages_model_ready.csv
│   │   │
│   │   ├─ otodom_housing_pages_model_ready.csv
│   │   ├─ Preparing_Model.ipynb
│   │   └─ random_forest_final_<timestamp>.pkl  (not included — see INSTRUCTION.md)
│   │
│   └─ 3._Prediction/
│       ├─ Prediction.py
│       ├─ Prediction.bat
│       ├─ City_Data.py
│       └─ random_forest_final_<timestamp>.pkl  (not included — see INSTRUCTION.md)
│
├─ INSTRUCTION.md
└─ README.md
```

---

## **Reproducibility & Next Steps**
**Reproducibility**
- All steps documented in `INSTRUCTION.md`.  
- Required input files and library versions listed in `requirements.txt`.
- The trained model is not committed to version control; running Part 2 regenerates it locally.

**Suggested Enhancements**
- Automate data acquasition/Improve UI of webscraper
- Fully automate data pipeline
