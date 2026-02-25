# Superstore Sales Dashboard - Power BI

## Overview

Interactive Power BI dashboard analyzing sales performance, profitability, and customer behavior for a U.S.-based retail superstore.  
The project provides comprehensive insights across geographic regions, product categories, and customer segments to drive data-informed business decisions.

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
- Quick identification of high-demand states and regions
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

### Customer & Trend Insights
- **Top Customers by Profit** - identification of highest-value customer accounts
- **Yearly Sales Trend** - time-series analysis of revenue patterns
- **Segment performance** - Consumer vs. Corporate vs. Home Office comparison

### Interactive Filtering
- **Year filter** - analyze specific annual periods
- **Month filter** - drill down to monthly granularity
- **Cross-filtering** - click any chart to dynamically filter all visuals
- **Dynamic KPI updates** - real-time metric recalculation based on selections

---

## Technical Implementation

### Data Model
- **Single fact table** structure with 9,994 rows
- **21 dimensional attributes** including:
  - Temporal dimensions (Order Date, Ship Date)
  - Geographic dimensions (State, City, Region)
  - Product dimensions (Category, Sub-Category, Product Name)
  - Customer dimensions (Segment, Customer Name)
  - Measure columns (Sales, Profit, Quantity, Discount)

### Power BI Features Used
- **Map visualization** - geographic bubble map for state-level analysis
- **Card visuals** - KPI display for key metrics
- **Bar charts** - profitability analysis by category/sub-category
- **Line charts** - temporal trend analysis
- **Slicers** - Year and Month filtering capabilities
- **Cross-filtering** - interactive drill-down functionality
- **DAX measures** - calculated metrics and aggregations

### Dashboard Design
- **Single-page layout** - all key insights on one view
- **Color-coded visualizations** - intuitive data interpretation
- **Responsive design** - adapts to different screen sizes
- **Performance-optimized** - fast rendering with ~10K rows

---

## Key Insights

### Geographic Performance
- **State-level variation**: Significant differences in order volume across 49 states
- **Regional patterns**: East, West, Central, and South regions show distinct performance characteristics
- **High-demand areas**: Map visualization reveals concentration of orders in specific states

### Product Category Analysis
- **Office Supplies dominance**: 60% of orders (6,026 transactions)
- **Category profitability**: Varies significantly by sub-category
- **Product mix**: 17 sub-categories provide granular insight into product performance
- **Profit leaders vs. laggards**: Bar charts highlight most/least profitable product lines

### Customer Behavior
- **Segment distribution**: Consumer segment represents majority (52%) of business
- **High-value customers**: Top customers drive disproportionate share of profit
- **Corporate opportunities**: 30% corporate segment represents B2B growth potential

### Temporal Trends
- **4-year historical data**: 2014-2017 trend analysis available
- **Seasonal patterns**: Yearly sales trend reveals cyclical behavior
- **Growth trajectories**: Year-over-year performance tracking

---

## Business Value

### Strategic Decision Support
- **Regional performance insights** - identify underperforming and high-potential markets
- **Product portfolio evaluation** - optimize inventory and focus based on profitability
- **Customer segmentation** - prioritize high-value customer relationships
- **Trend monitoring** - track sales and profitability patterns over time

### Operational Applications
- **Resource allocation** - deploy sales teams to high-opportunity regions
- **Inventory management** - stock products based on category performance
- **Pricing strategy** - analyze discount impact on profitability
- **Customer relationship management** - focus retention efforts on top customers

### Performance Monitoring
- **Real-time KPI tracking** - monitor key business metrics at a glance
- **Comparative analysis** - benchmark performance across segments, regions, products
- **Anomaly detection** - identify unusual patterns requiring attention
- **Goal tracking** - measure progress against business objectives

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
