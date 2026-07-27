import warnings
warnings.filterwarnings('ignore')
import joblib
import pandas as pd
from City_Data import MIASTO_REGION, MIASTO_DZIELNICE

# Ścieżka do modelu
MODEL_PATH = "random_forest_final_20260102_134940.pkl"

def predict_price(pokoje, powierzchnia_m2, pietro, dzielnica, miasto, region):
    """Przewiduje cenę mieszkania"""
    model = joblib.load(MODEL_PATH)
    
    X = pd.DataFrame({
        'pokoje': [pokoje],
        'powierzchnia_m2': [powierzchnia_m2],
        'pietro': [pietro],
        'dzielnica': [dzielnica],
        'miasto': [miasto],
        'region': [region]
    })
    
    return model.predict(X)[0]

if __name__ == "__main__":
    print("\nPredykcja ceny mieszkania\n")
    while True:
        try:
            pokoje = int(input("Liczba pokoi: "))
            powierzchnia = float(input("Powierzchnia (m²): "))
            pietro = int(input("Piętro: "))
            
            print("\nDostępne miasta:")
            miasta_lista = sorted(MIASTO_REGION.keys())
            for i, m in enumerate(miasta_lista, 1):
                print(f"  {i}. {m}")
            print()
            miasto = input("Miasto: ").lower().strip()
            
            if miasto not in MIASTO_REGION:
                print(f"Nieznane miasto: {miasto}")
                continue
            
            if miasto in MIASTO_DZIELNICE:
                print(f"\nDostępne dzielnice w mieście {miasto.capitalize()}:")
                for i, dz in enumerate(MIASTO_DZIELNICE[miasto], 1):
                    print(f"  {i}. {dz}")
                print()
            
            dzielnica = input("Dzielnica: ").lower().strip()
            
            # Automatyczne przypisanie regionu
            region = MIASTO_REGION[miasto]

            print("\nPodsumowanie wprowadzonych danych:")
            print(f"  Liczba pokoi     : {pokoje}")
            print(f"  Powierzchnia     : {powierzchnia} m²")
            print(f"  Piętro           : {pietro}")
            print(f"  Miasto           : {miasto}")
            print(f"  Dzielnica        : {dzielnica}")
            print(f"  Region           : {region}")

            # Predykcja
            cena = predict_price(pokoje, powierzchnia, pietro, dzielnica, miasto, region)
            
            print(f"\n Przewidywana cena: {cena:,.2f} PLN")
            print(f"   Cena za m²: {cena/powierzchnia:,.2f} PLN/m²\n")
            
            kontynuuj = input("Chcesz wykonać kolejną predykcję? (tak/nie): ").lower()
            if kontynuuj not in ['tak', 't', 'yes', 'y']:
                print("\nDo widzenia!\n")
                break
            print()
            
        except KeyboardInterrupt:
            print("\n\nPrzerwano.\n")
            break
        except Exception as e:
            print(f"\nBłąd: {e}")
            print("Spróbuj ponownie.\n")