# Superstore Sales Dashboard - Power BI

## Overview

Interactive Power BI dashboard analyzing sales performance, profitability, and customer behavior for a U.S.-based retail superstore.  
The project compares performance across geographic regions, product categories, customer segments, and time periods.

Dataset source: [Kaggle - Superstore Dataset](https://www.kaggle.com/code/tarekmasryo/data-analysis-for-superstore-dataset)

---

## Dataset Scope

- **9,994 transactions** from retail operations
- **Time period**: 2014-2017 (4 years)
- **Geographic coverage**: 49 U.S. states across 4 regions (East, West, Central, South)
- **Product range**: 3 main categories, 17 sub-categories
  - Office Supplies (6,026 orders)
  - Furniture (2,121 orders)
  - Technology (1,847 orders)
- **Customer segments**: Consumer (52%), Corporate (30%), Home Office (18%)
- **21 attributes** per transaction including sales, profit, discount, quantity

### Key Metrics Available
- Sales revenue
- Profit/Loss
- Discount rates
- Order quantities
- Customer information
- Geographic data (State, City, Region)
- Shipping details
- Product classifications

---

## Key Features

### Geographic Analysis
- **Interactive map visualization** with proportional bubbles
- Darker and larger bubbles indicate higher order volume
- Identification of states and regions with the highest order volume
- Regional performance comparison

### Core KPIs
- **Unique Products** - total distinct products sold
- **Unique Customers** - customer base size
- **Unique Orders** - total transaction count
- **Total Profit** - overall profitability metric

### Profitability Analysis
- **Profit by Sub-Category** - horizontal bar chart showing most/least profitable product lines
- **Profit by Category** - category-level profitability comparison
- **Category Sales Share** - revenue distribution across product categories

### Customer & Trend Analysis
- **Top Customers by Profit** - identification of customers generating the highest total profit
- **Yearly Sales Trend** - time-series analysis of revenue patterns
- **Segment Performance** - Consumer vs Corporate vs Home Office comparison

### Interactive Filtering
- **Year filter** - analyze specific annual periods
- **Month filter** - filter data to monthly granularity
- **Cross-filtering** - click a visual to dynamically filter related report visuals
- **Dynamic KPI updates** - metrics recalculate based on the active filter context

---

## Technical Implementation

### Data Structure
- **Single-table model** with 9,994 rows
- **21 attributes** including:
  - Temporal fields (Order Date, Ship Date)
  - Geographic fields (State, City, Region)
  - Product fields (Category, Sub-Category, Product Name)
  - Customer fields (Segment, Customer Name)
  - Measure columns (Sales, Profit, Quantity, Discount)

### Power BI Features Used
- **Map visualization** - geographic bubble map for state-level analysis
- **Card visuals** - KPI display for key metrics
- **Bar charts** - profitability analysis by category/sub-category
- **Line charts** - temporal trend analysis
- **Slicers** - Year and Month filtering
- **Cross-filtering** - interactions between report visuals
- **DAX measures** - calculated metrics and aggregations

### Dashboard Design
- **Single-page layout** - key KPIs and analyses available in one report view
- **Consistent visual structure** - geographic, product, customer, and temporal analyses organized in separate areas

---

## Key Insights

### Geographic Performance
- **Order distribution**: Order volume varies across U.S. states and can be compared interactively using the map
- **Regional comparison**: East, West, Central, and South regions can be compared within the same report view

### Product Category Analysis
- **Office Supplies dominance**: Office Supplies account for 60% of transactions (6,026 orders)
- **Category profitability**: Profitability varies across categories and sub-categories
- **Product coverage**: 17 sub-categories provide a more granular view of product performance

### Customer Analysis
- **Segment distribution**: Consumer accounts for 52% of transactions in the dataset
- **Customer profitability**: The dashboard identifies customers generating the highest total profit
- **Corporate segment**: Corporate customers account for 30% of transactions, enabling comparison with Consumer and Home Office segments

### Temporal Analysis
- **Historical coverage**: Four years of data (2014-2017) are available for year-over-year comparison
- **Sales trends**: The dashboard supports comparison of sales performance across years and months

---

## Business Value

- **Performance monitoring** - compare sales and profitability across regions, products, and customer segments
- **Product analysis** - identify higher- and lower-profit categories and sub-categories
- **Customer analysis** - identify customers contributing the highest total profit
- **Trend analysis** - monitor changes in sales performance across years and months

---

## Tools & Technologies

- **Power BI Desktop** - dashboard development and data modeling
- **DAX (Data Analysis Expressions)** - measure calculations
- **Power Query** - data transformation and preparation
- **Interactive visualizations** - maps, charts, cards, slicers
- **Cross-filtering** - dynamic dashboard interactivity

---

## Files Structure

- `Superstore_Data_Insights.pbix` - Power BI dashboard file containing:
  - Data model
  - Visualizations (map, charts, KPIs)
  - DAX measures
  - Interactive filters
  - Design layout
- `Sample_-_Superstore.csv` - source dataset (9,994 rows, 21 columns)
