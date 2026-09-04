# **CenoMetr — Apartment Price Prediction**

## **Overview**

**CenoMetr** is a predictive system for estimating apartment prices based on listing data collected from Otodom.  
The project combines web scraping, data cleaning, feature engineering, and machine learning to produce model-based apartment value estimates.

**Project Goal**

Build a repeatable end-to-end pipeline enabling:
- prediction of total apartment price using listing data,
- calculation of estimated price per square meter from the predicted total value,
- analysis of how location and property features influence apartment pricing,
- a practical CLI tool for generating and comparing model-based price estimates.

---

## **Data Scope & Key Challenges**

**Data Source**
- Listing data collected from Otodom, covering 20 major Polish cities.

**Key Fields**
- `price`, `area_m2`, `rooms`, `floor`, `district`, `city`, `region`.

**Main Data Quality Challenges**
- **Listing vs transaction prices** — asking prices may differ from final transaction values.
- **Missing & inconsistent fields** — incomplete entries and inconsistent location formats.
- **Duplicates & outliers** — repeated listings and extreme values in price or area.
- **Regional variability** — strong differences between local housing markets require location context.

---

## **Architecture & Pipeline**

### **Processing Stages**

1. **Data Acquisition**
   - Web scraping using **Selenium** + **geckodriver** collected apartment listings across 20 Polish cities.
   - The scraping module itself is not included in this public repository; the generated datasets are provided directly.

2. **Initial Cleaning**
   - Duplicate removal
   - Price, area, and date standardization
   - Basic missing-value filtering

3. **Data Cleaning & Deduplication (Python)**
   - Dropping helper columns
   - Filtering rows with missing district or room values
   - Removing exact duplicate listings
   - Filtering implausible area values
   - Output saved as `otodom_housing_pages_model_ready.csv`

4. **Feature Engineering**
   - Encoding categorical variables such as district, city, and region
   - Grouping low-sample districts (<50 listings) into a shared `other` category to reduce sparsity
   - Price per m² is derived from the predicted total price and apartment area; it is not used as a model input

5. **Modeling**
   - Compared:
     - Random Forest
     - Decision Tree
     - HistGradientBoosting
   - Models evaluated with and without district-level features
   - Final model: **Random Forest**
   - Hyperparameter tuning, cross-validation, and test-set evaluation applied
   - Modeling scope limited to the mainstream market (≤3M PLN, ≤400 m²)

6. **Model Serialization & Prediction**
   - Final model saved locally as `random_forest_final_<timestamp>.pkl`
   - CLI prediction module loads the trained model and returns:
     - predicted total apartment price
     - derived price per square meter
   - The trained `.pkl` file is not included in the repository due to its size

### **Key Files**
- `otodom_housing_pages_clean.csv` → `Preliminary_cleaning.py` → `otodom_housing_pages_model_ready.csv`
- `Preparing_Model.ipynb`
- `random_forest_final_<timestamp>.pkl` *(generated locally, not included in the repository)*
- `Prediction.py`
- `Prediction.bat`
- `City_Data.py`

---

## **Technologies & Tools**

### **Language & Environment**
- Python 3.10+
- Jupyter Notebook
- VS Code
- Virtual environment (`venv`)

### **Libraries & Tools**
- **pandas**, **numpy** — data processing
- **scikit-learn** — model training, validation, tuning
- **selenium** + **geckodriver** — data acquisition
- **joblib** — model serialization
- **matplotlib**, **seaborn** — visualizations and analysis

---

## **Modeling Methodology & Validation**

### **Practices Used**
- Train / validation / test split
- Cross-validation for more stable performance estimates
- Outlier handling and market-scope filtering
- Hyperparameter tuning for Random Forest
- Model comparison across multiple algorithms
- Final model export to `.pkl`

> Model evaluation metrics are generated inside `Preparing_Model.ipynb`.  
> They are not duplicated here to avoid presenting values that may change when the model is retrained.

---

## **Key Results**

### **Technical Results**
- Final selected model: **Random Forest**
- Predicts total apartment price from property and location features
- Supports city- and district-level location context
- Derives price per m² from the predicted total value and apartment area
- Provides a local CLI interface for inference

### **Practical Applications**
- Generate model-based apartment price estimates
- Compare predicted values across different property configurations
- Evaluate how location and property characteristics influence estimated pricing
- Use the CLI as a lightweight interface for local model inference

---

## **How to Run**

All setup instructions are provided in `INSTRUCTION.md`.

The trained model is not shipped with the repository.  
Part 2 of the guide trains and exports a fresh local model before the prediction module is used.

---

## **Reproducibility**

- Data cleaning is automated through `Preliminary_cleaning.py`
- Model preparation and training are documented in `Preparing_Model.ipynb`
- Required libraries are listed in `requirements.txt`
- The trained model is regenerated locally instead of being committed to version control

> Cleaning was originally performed manually in Excel / Power Query and was later replaced with a fully automated Python workflow.

---

## **Repository Structure**

```text
CenoMetr_App/
├─ CenoMetr/
│  ├─ 1._Webscraping_Otodom/
│  │  ├─ requirements.txt
│  │  ├─ otodom_housing_pages.csv
│  │  └─ otodom_housing_pages_clean.csv
│  │
│  ├─ 2._Training_and_Testing_Models/
│  │  ├─ Data_Cleaning/
│  │  │  ├─ Preliminary_cleaning.py
│  │  │  ├─ otodom_housing_pages_clean.csv
│  │  │  └─ otodom_housing_pages_model_ready.csv
│  │  │
│  │  ├─ otodom_housing_pages_model_ready.csv
│  │  ├─ Preparing_Model.ipynb
│  │  └─ random_forest_final_<timestamp>.pkl
│  │
│  └─ 3._Prediction/
│     ├─ Prediction.py
│     ├─ Prediction.bat
│     ├─ City_Data.py
│     └─ random_forest_final_<timestamp>.pkl
│
├─ INSTRUCTION.md
└─ README.md
```

---

## **Future Enhancements**

- Automate data acquisition and improve the scraper interface
- Build a fully automated ETL / retraining pipeline
- Add an API or lightweight web interface for model inference
- Integrate transaction-price data to complement listing-based training data
