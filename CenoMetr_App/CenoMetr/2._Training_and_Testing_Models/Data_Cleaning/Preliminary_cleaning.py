import pandas as pd

INPUT_CSV = "otodom_housing_pages_clean.csv"
OUTPUT_CSV = "otodom_housing_pages_model_ready.csv"

df = pd.read_csv(INPUT_CSV)
print(f"Loaded: {df.shape[0]} rows, {df.shape[1]} columns")

# 1. Drop columns not needed for modeling 

df = df.drop(columns=["tytul", "link", "strona"])

# 2. Drop rows missing key fields

before = len(df)
df = df.dropna(subset=["dzielnica", "pokoje"])
print(f"Dropped {before - len(df)} rows with missing dzielnica/pokoje")

# 3. Remove exact duplicate listings 

before = len(df)
df = df.drop_duplicates(
    subset=["cena", "pokoje", "powierzchnia_m2", "pietro", "dzielnica", "miasto", "region"]
)
print(f"Dropped {before - len(df)} exact duplicate listings")

# 4. Remove implausible area values 

before = len(df)
df = df[df["powierzchnia_m2"] <= 500]
print(f"Dropped {before - len(df)} rows with implausible area (>500 m^2)")

df.to_csv(OUTPUT_CSV, index=False)
print(f"\nFinal dataset: {df.shape[0]} rows, {df.shape[1]} columns -> {OUTPUT_CSV}")
