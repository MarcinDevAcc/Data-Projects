# Ultimate Cars Dataset 2024 - Automotive Market Analysis (Excel)

## Overview

Multi-dimensional analysis of the global automotive market covering 1,213 vehicle models from 31 manufacturers.  
The project compares pricing, performance metrics, fuel types, and market positioning across luxury, performance, and mainstream vehicle categories.

Dataset source: [Kaggle - Ultimate Cars Dataset 2024](https://www.kaggle.com/datasets/abdulmalik1518/the-ultimate-cars-dataset-2024/data)  
Dataset author: [Abdul Malik](https://www.kaggle.com/abdulmalik1518)

---

## Dataset Scope

### Coverage
- **1,213 vehicles** across 31 automotive brands
- **Price range**: $4,000 - $18,000,000 (Bugatti La Voiture Noire)
- **Power output**: 26 HP - 1,850 HP
- **Top speed**: 80 km/h - 500 km/h
- **Seating capacity**: 1-20 seats

### Key Attributes
- Company/Brand names
- Vehicle model names
- Engine specifications
- CC/Battery capacity
- Horsepower (standard and max)
- Top speed (km/h)
- Acceleration (0-100 km/h)
- Pricing
- Fuel type (Petrol, Diesel, Hybrid, Electric, Hydrogen)
- Seating configuration
- Torque ratings

---

## Analysis Components

### Performance Analysis
- **Top 10 Cars by Horsepower** - highest-performance vehicles with detailed specs
- **Top 10 Cars by Top Speed** - fastest vehicles across all categories
- **Average HP per Company** - brand-level performance comparison
- **Average HP by Company & Fuel Type** - multi-dimensional performance matrix

### Pricing Analysis
- **Price Range Distribution** - market segmentation by price brackets
- **Top 5 Most Expensive Companies** - luxury brand positioning
- **Average Car Price per Company** - brand-level price comparison
- **10 Companies with Cheapest HP** - performance-to-price comparison

### Market Segmentation
- **Fuel Type Distribution** - Petrol: 894, Diesel: 110, Hybrid: 109, Electric: 97, Hydrogen: 3
- **Seat Distribution** - 5-seat vehicles are the largest group (688 vehicles)
- **Average Performance per Fuel Type** - acceleration comparison by powertrain

---

## Technical Implementation

### Data Processing
- Raw data normalization
- Fuel type standardization ("Fuel Type fixed" column)
- Price range categorization
- Data quality validation

### Analytical Tools
- **8 Pivot Tables** for multi-dimensional aggregation
- **7 Visualizations**:
  - Bar charts (performance rankings, price distributions, brand comparisons)
  - Line charts (fuel type and seat distributions)
- Separate data preparation sheets for each visualization
- Cross-sheet references for dynamic updates

### Workbook Architecture
- RAW DATA sheet (source of truth)
- Analytical sheets (aggregations and calculations)
- Visualization sheets (pivot tables + charts)
- Modular structure for easier maintenance

---

## Key Insights

### Performance
- **Extreme performance**: Bugatti La Voiture Noire is listed at $18M with 1,500 HP
- **Performance leaders**: Supercar and hypercar manufacturers appear prominently among the highest horsepower and top-speed models
- **Average power output**: Vehicles in the dataset average 308 HP

### Market Composition
- **Fuel type distribution**: Petrol dominates the dataset at 73.7%, while hybrid and electric vehicles represent approximately 9% and 8%
- **Seating distribution**: 56.7% of vehicles are 5-seaters
- **Price distribution**: Median vehicle price is $42,000, while the mean is influenced by ultra-luxury models

### Brand Positioning
- **Luxury segment**: Bugatti, Rolls-Royce, and Bentley occupy the highest price ranges
- **Performance segment**: Ferrari, Lamborghini, and McLaren combine high horsepower with premium pricing
- **Mainstream segment**: Honda, Toyota, and Ford appear in more accessible price ranges compared with exotic and ultra-luxury manufacturers

---

## Business Applications

- **Market comparison** - compare manufacturers across pricing and performance metrics
- **Performance benchmarking** - evaluate differences in horsepower, top speed, and acceleration
- **Price positioning** - compare brands and models across price segments
- **Vehicle comparison** - assess performance-to-price relationships across manufacturers

---

## Tools & Technologies

- Microsoft Excel
- Pivot Tables (8 tables)
- Data visualization (bar charts, line charts)
- Multi-sheet workbook architecture
- Statistical aggregation functions
- Data transformation and normalization

---

## Files Structure

- `RAW_DATA_Ultimate_Cars_Dataset_2024.csv` - source data (1,213 vehicles, 13 attributes)
- `WORKSHEET_Ultimate_Cars_Dataset_2024.xlsx` - complete analysis workbook containing:
  - RAW DATA Ultimate Cars Data sheet (source)
  - Analytical preparation sheets (aggregations)
  - Visualization sheets with pivot tables and charts:
    - Top 10 Cars by HP Vis
    - Top 10 Cars by Total Speed Vis
    - Price Range Distribution Vis
    - Top 5 Most exp. Companies Vis
    - Seat Distribution Vis
    - Distribution of Fuel Types Vis
    - 10 Comp. with Cheapest HP Vis
