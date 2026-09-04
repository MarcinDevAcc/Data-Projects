# Tile Store Orders - RFM Analysis (Excel)

## Overview

Customer segmentation project using RFM (Recency, Frequency, Monetary) analysis methodology.  
The project analyzes purchasing patterns of 245 customers across 1,000 orders to identify customer segments and support targeted customer analysis.

---

## Dataset Scope

- **1,000 orders** from tile retail operations
- **245 unique customers** tracked
- **Time period**: 2024-2026 (synthetic dataset)
- **Business domain**: Tile retail store
- **Product categories**: 8 tile types (Ceramic, Porcelain, Marble, Granite, Mosaic, Vinyl, Terracotta, Glass)
- **Data source**: Python-generated synthetic dataset with realistic patterns

---

## Key Features

### Data Generation
- **Python Jupyter Notebook** for synthetic dataset creation
- Realistic order patterns with randomized dates, customers, and values
- CSV export with European formatting (semicolon separator, comma decimal)
- Configurable parameters (1,000 orders, 250 customer pool, 8 product types)

### RFM Metrics Calculation
- **Recency** - days since last purchase (lower is better)
- **Frequency** - total number of orders (higher is better)
- **Monetary** - total order value (higher is better)
- **Scoring system** - 1-5 scale for each metric using quantile-based distribution

### Customer Segmentation
Five distinct customer segments identified:
- **Best Customers** (43 customers, RFM Score 13-15) - highest combined RFM scores
- **Loyal Customers** (78 customers, RFM Score 10-12) - consistently strong RFM performance
- **Potential Loyal Customers** (73 customers, RFM Score 7-9) - mid-range RFM scores with room for further engagement
- **Need Attention** (43 customers, RFM Score 4-6) - lower combined RFM performance
- **At Risk** (8 customers, RFM Score 3) - lowest combined RFM scores

---

## Technical Implementation

### Data Model Architecture

**Source Data (tile_store_orders)**
- order_id
- customer_id
- order_date
- product_type
- order_value

**Aggregated Metrics (Pivot_1)**
- Customer-level aggregation via Pivot Table
- Recency calculation (days from reference date)
- Frequency and monetary totals

**RFM Scoring (RFM_Score)**
- Quantile-based scoring (1-5 scale per metric)
- Composite RFM score (sum of R+F+M)
- Segment assignment logic

**Summary (RFM_Category_Count)**
- Customer count by segment
- Distribution overview

### Excel Techniques Used
- Pivot Tables for aggregation
- Dynamic Array Formulas for scoring
- Quantile-based statistical analysis
- Conditional logic for segmentation

---

## Key Insights

### Customer Distribution
- **Best Customers**: 17.6% of customer base (43/245)
- **Loyal Customers**: 31.8% - largest segment (78/245)
- **Potential Loyal**: 29.8% (73/245)
- **Need Attention**: 17.6% (43/245)
- **At Risk**: 3.3% (8/245)

### Segment Structure
- **Strong RFM segments**: Nearly 50% of customers fall into Best Customers or Loyal Customers
- **Mid-range segment**: 29.8% of customers are classified as Potential Loyal
- **Lower-engagement segments**: 21% of customers fall into Need Attention or At Risk categories

---

## Business Value

### Strategic Applications
- **Targeted marketing** - use customer segments to tailor communication and offers
- **Retention analysis** - identify lower-engagement customer groups for further investigation
- **Customer prioritization** - distinguish customers with stronger and weaker RFM profiles
- **Growth analysis** - identify customers with mid-range scores who may have potential for stronger engagement

### Example Segment Applications
- **Best Customers**: loyalty rewards, exclusive offers, VIP treatment
- **Loyal Customers**: maintain engagement and explore upsell opportunities
- **Potential Loyal**: encourage repeat purchases and stronger engagement
- **Need Attention**: evaluate win-back or re-engagement campaigns
- **At Risk**: prioritize for further retention analysis and targeted outreach

---

## Tools & Technologies

### Data Generation
- Python 3
- Jupyter Notebook
- pandas, numpy, random, datetime libraries

### Analysis & Modeling
- Microsoft Excel
- Pivot Tables
- Dynamic Array Formulas
- Quantile-based statistical analysis
- Customer segmentation methodology (RFM)

---

## Files Structure

- `Tile_store_dataset_generator.ipynb` - Python script for synthetic data generation
- `tile_store_orders.csv` - raw order data (1,000 transactions)
- `Tile_Store_Orders_Analysis.xlsx` - Excel workbook containing:
  - tile_store_orders sheet (source data)
  - Pivot_1 sheet (customer aggregations)
  - RFM_Score sheet (scoring and segmentation)
  - RFM_Category_Count sheet (segment summary)
