# Coffee Sales Dashboard - Excel

## Overview

Interactive Excel dashboard analyzing coffee sales performance across multiple dimensions.  
The project tracks sales trends, customer behavior, and product performance for a coffee retail business operating in the United States, Ireland, and United Kingdom.

---

## Dataset Scope

- **1,000+ orders** from coffee retail operations
- **Time period**: 2019-2021
- **Geographic coverage**: United States, Ireland, United Kingdom
- **Product range**: 4 coffee types (Arabica, Excelsa, Liberica, Robusta)
- **Configuration options**: Multiple roast types and package sizes
- **Customer base**: Tracked with loyalty program status

---

## Key Features

### Data Integration & Transformation
- **XLOOKUP functions** for customer data retrieval (name, email, country, loyalty status)
- **INDEX-MATCH formulas** for product information lookup (type, roast, size, pricing)
- **Calculated fields** for sales computation and data normalization
- **IF statements** for category name conversion (abbreviated codes → full names)

### Interactive Filtering
- Timeline slicer for date-based analysis (monthly granularity)
- Size filter (0.2 kg, 0.5 kg, 1.0 kg, 2.5 kg)
- Roast type selector (Dark, Light, Medium)
- Loyalty card status filter (Yes/No)

### Visual Analytics
- **Sales Trend Line Chart** - time series analysis by coffee type (Arabica, Excelsa, Liberica, Robusta)
- **Sales by Country** - horizontal bar chart showing geographic distribution
- **Top 5 Customers** - ranking of highest-value customers by total sales

---

## Technical Implementation

### Workbook Data Structure
- **Orders table** - main transactional data with computed fields
- **Customers table** - customer profiles and loyalty information
- **Products table** - product catalog with pricing structure
- **Supporting sheets** - aggregated data for chart sources

### Excel Functions Used
- XLOOKUP
- INDEX-MATCH
- IF (nested)
- Basic arithmetic calculations

### Dashboard Structure
- Cross-sheet references
- Slicers for dynamic filtering
- Multiple chart types
- Data validation

---

## Key Insights

- **Sales trends**: Sales performance varies across time periods and coffee types
- **Geographic performance**: United States represents the largest market in the dataset
- **Customer concentration**: Top-customer ranking highlights accounts with the highest total sales
- **Product comparison**: Dashboard filters allow roast type and package size performance to be compared across selected periods

---

## Business Value

- **Sales monitoring** - track changes in sales performance over time and by coffee type
- **Geographic comparison** - compare performance across the United States, Ireland, and United Kingdom
- **Customer analysis** - identify customers generating the highest total sales
- **Product analysis** - compare sales across roast types and package sizes

---

## Tools & Technologies

- Microsoft Excel
- Lookup formulas (XLOOKUP, INDEX-MATCH)
- Interactive dashboards
- Multi-table workbook structure

---

## Files Structure

- `coffeeOrdersData.xlsx` - Excel workbook containing:
  - orders sheet (transactional data)
  - customers sheet (customer profiles)
  - products sheet (product catalog)
  - Dashboard sheet (interactive visualizations)
  - Supporting calculation sheets
