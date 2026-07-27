# **Project Setup Guide**

> **Operating system:** Windows  
> **Required knowledge:** None — every step is explained clearly

---

## **Table of Contents**

1. [Project Structure](#1-project-structure)  
2. [Prerequisites](#2-prerequisites)  
3. [Installing Python](#3-installing-python)  
4. [Installing Visual Studio Code](#4-installing-visual-studio-code)  
5. [Installing Jupyter Notebook](#5-installing-jupyter-notebook)  
6. [Creating a Virtual Environment](#6-creating-a-virtual-environment)  
7. [Installing Dependencies](#7-installing-dependencies)  
8. [Part 1 — Data Collection (Provided)](#8-part-1--data-collection-provided)  
9. [Running Part 2 — Model Training](#9-running-part-2--model-training)  
10. [Running Part 3 — Prediction](#10-running-part-3--prediction)  
11. [Troubleshooting](#11-troubleshooting)

---

## **1. Project Structure**

The project lives inside the `CenoMetr` folder, alongside this guide and the README, and consists of three stage folders:

```
CenoMetr_App/
├── CenoMetr/
│   ├── 1._Webscraping_Otodom/
│   │   ├── requirements.txt                          ← list of required libraries (for the entire project)
│   │   ├── otodom_housing_pages.csv                  ← raw scraped data (provided directly, see note below)
│   │   └── otodom_housing_pages_clean.csv             ← initial cleaned data (Python preprocessing)
│   │
│   ├── 2._Training_and_Testing_Models/
│   │   ├── Data_Cleaning/
│   │   │   ├── Preliminary_cleaning.py                ← script for additional preprocessing before modeling
│   │   │   ├── otodom_housing_pages_clean.csv          ← input file from Part 1
│   │   │   └── otodom_housing_pages_model_ready.csv    ← fully cleaned dataset ready for modeling
│   │   │
│   │   ├── otodom_housing_pages_model_ready.csv        ← copy used by the training notebook
│   │   ├── Preparing_Model.ipynb                       ← notebook for training ML models (Random Forest)
│   │   └── random_forest_final_<timestamp>.pkl          ← trained model (generated locally, not included in repo)
│   │
│   └── 3._Prediction/
│       ├── Prediction.py                                ← main prediction script (terminal interface)
│       ├── Prediction.bat                                ← one‑click launcher for Prediction.py
│       ├── City_Data.py                                  ← module containing city/district definitions
│       └── random_forest_final_<timestamp>.pkl          ← copy of the trained model (not included in repo)
│
├── INSTRUCTION.md
└── README.md
```

> **Note:** Two things are intentionally not included in this repository:
> - The **web scraping notebook**, out of respect for the target site's terms of service. The listing data it produced is provided directly (`otodom_housing_pages.csv`, `otodom_housing_pages_clean.csv`), so setup starts at Part 2 below.
> - The **trained model file** (`.pkl`, ~367 MB), to keep the repository lightweight. You will train your own copy in Part 2 before Part 3 (Prediction) can run.

> **Important:** Run the project in order — Model Training → Prediction. Each part depends on the output of the previous one.

---

## **2. Prerequisites**

Make sure you have the following installed:

| Program | Version | Purpose |
|--------|---------|---------|
| Python | 3.10 or newer | main programming language |
| Visual Studio Code | latest | editor for running notebooks |

---

## **3. Installing Python**

1. Go to: [https://www.python.org/downloads/](https://www.python.org/downloads/)  
2. Click **Download Python 3.x.x**  
3. Run the downloaded `.exe` installer  
4. **Important:** check **“Add Python to PATH”**  
5. Click **Install Now**  
6. Verify installation in Command Prompt:

```
python --version
```

You should see something like `Python 3.12.4`.

---

## **4. Installing Visual Studio Code**

1. Go to: [https://code.visualstudio.com/](https://code.visualstudio.com/)  
2. Download and install VS Code  
3. During installation, check **“Add to PATH”**  
4. Open VS Code  
5. Install extensions:
   - **Python** (Microsoft)
   - **Jupyter** (Microsoft)

---

## **5. Installing Jupyter Notebook**

You can use Jupyter in two ways:

### **Option A — via VS Code (recommended)**  
The Jupyter extension automatically handles `.ipynb` files.  
Just open the notebook — no extra installation needed.

### **Option B — classic Jupyter Notebook**

Install it after activating the virtual environment:

```
pip install notebook
```

Run:

```
jupyter notebook
```

---

## **6. Creating a Virtual Environment**

1. Open the project's root folder (the one containing `CenoMetr/`, `README.md`, and `INSTRUCTION.md`) in VS Code  
2. Open terminal: **Terminal → New Terminal**  
3. Create the environment:

```
python -m venv venv
```

4. Activate it:

```
venv\Scripts\activate
```

5. Select the interpreter in VS Code:
   - `Ctrl+Shift+P` → **Python: Select Interpreter** → choose the one with `venv`

---

## **7. Installing Dependencies**

All required libraries are listed in:

```
CenoMetr/1._Webscraping_Otodom/requirements.txt
```

Install them:

```
cd "CenoMetr/1._Webscraping_Otodom"
pip install -r requirements.txt
```

---

## **8. Part 1 — Data Collection (Provided)**

> **Goal:** Understand where the listing data comes from.

The web scraping module (Selenium + geckodriver) used to originally collect this data is **not included** in this public repository, out of respect for the target site's terms of service.

The data it produced is provided directly in `1._Webscraping_Otodom/`:
- `otodom_housing_pages.csv` — raw scraped listings
- `otodom_housing_pages_clean.csv` — after initial Python-side cleaning

No action is needed here — proceed directly to Part 2.

---

## **9. Running Part 2 — Model Training**

> **Goal:** Prepare the dataset and train the Random Forest model.

---

### **Step 1 — Move the input file**

Copy:

```
CenoMetr/1._Webscraping_Otodom/otodom_housing_pages_clean.csv
```

to:

```
CenoMetr/2._Training_and_Testing_Models/Data_Cleaning/
```

---

### **Step 2 — Automatic data cleaning**

Run the cleaning script:

```
cd "CenoMetr/2._Training_and_Testing_Models/Data_Cleaning"
python Preliminary_cleaning.py
```

This generates:

```
otodom_housing_pages_model_ready.csv
```

---

### **Step 3 — Move cleaned file**

Copy the cleaned file to:

```
CenoMetr/2._Training_and_Testing_Models/
```

---

### **Step 4 — Train the model**

Open:

```
CenoMetr/2._Training_and_Testing_Models/Preparing_Model.ipynb
```

Run all cells using the `venv` kernel.

A trained model file will appear:

```
random_forest_final_<timestamp>.pkl
```

---

### **Step 5 — Prepare for prediction**

Copy the `.pkl` model file to:

```
CenoMetr/3._Prediction/
```

---

## **10. Running Part 3 — Prediction**

> **Goal:** Predict apartment prices based on user‑provided parameters.

### Requirements

- Your own trained `random_forest_final_<timestamp>.pkl` in the Prediction folder (not shipped with this repo — see Part 2)  
- `Prediction.py` and `City_Data.py` present  
- `MODEL_PATH` in `Prediction.py` updated to match your model's exact filename

### **Option 1 — Using the .bat file**

Double‑click:

```
Prediction.bat
```

A terminal window will open and guide you through the input process.

### **Option 2 — Using VS Code terminal**

```
cd "CenoMetr/3._Prediction"
..\..\venv\Scripts\activate
python Prediction.py
```

---

## **11. Troubleshooting**

**Python not recognized**  
→ Reinstall Python and check “Add Python to PATH”.

**Virtual environment activation error**  
→ Run:
```
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

**Model file not found**  
→ Expected until you complete Part 2 — the trained model isn't included in this repository. Ensure `MODEL_PATH` in `Prediction.py` matches your generated `.pkl` filename exactly.

**CSV file not found in training notebook**  
→ Ensure `otodom_housing_pages_model_ready.csv` is in `2._Training_and_Testing_Models`.

**ModuleNotFoundError**  
→ Activate `venv` and reinstall dependencies:

```
pip install -r requirements.txt
```
