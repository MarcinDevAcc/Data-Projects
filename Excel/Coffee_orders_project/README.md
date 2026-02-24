# Coffee Sales Dashboard - Excel

## Overview

Interactive Excel dashboard analyzing coffee sales performance across multiple dimensions.  
The project tracks sales trends, customer behavior, and product performance for a coffee retail business operating in the United States, Ireland, and United Kingdom.

Data period: 2019-2021  
Dataset: 1,000+ orders across 4 coffee types and multiple product configurations

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

### Data Model
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

## Business Value

- **Trend identification** - seasonal patterns and growth trajectories by coffee type
- **Geographic insights** - market performance comparison across countries
- **Customer segmentation** - identification of high-value customers
- **Product mix analysis** - understanding of size and roast preferences
- **Loyalty impact assessment** - ability to filter by loyalty card status

---

## Tools

- Microsoft Excel
- Advanced formulas (XLOOKUP, INDEX-MATCH)
- Interactive dashboards
- Data modeling across multiple tables
