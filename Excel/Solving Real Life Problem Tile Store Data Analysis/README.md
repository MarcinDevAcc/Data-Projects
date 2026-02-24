# Tile Store Orders - RFM Analysis (Excel)

## Overview

Advanced customer segmentation project using RFM (Recency, Frequency, Monetary) analysis methodology.  
The project analyzes purchasing patterns of 245 customers across 1,000 orders to identify customer segments and prioritize marketing efforts.

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
- **Best Customers** (43 customers, RFM Score 13-15) - highest engagement and value
- **Loyal Customers** (78 customers, RFM Score 10-12) - consistent buyers with good value
- **Potential Loyal Customers** (73 customers, RFM Score 7-9) - growth opportunity segment
- **Need Attention** (43 customers, RFM Score 4-6) - declining engagement
- **At Risk** (8 customers, RFM Score 3) - lowest metrics, churn risk

### Technical Implementation
- **Pivot Table** for per-customer aggregation:
  - Max order date (most recent purchase)
  - Count of orders (frequency)
  - Sum of order value (monetary total)
- **Dynamic Array Formulas** for RFM scoring
- **Automated categorization** based on composite RFM score
- **Summary tables** showing segment distribution

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
- **Potential Loyal**: 29.8% - significant growth opportunity (73/245)
- **Need Attention**: 17.6% - at-risk of churn (43/245)
- **At Risk**: 3.3% - urgent intervention required (8/245)

### Segment Characteristics
- **High-value concentration**: Top 17.6% (Best Customers) likely drive disproportionate revenue
- **Loyalty strength**: Nearly 50% fall into Best/Loyal categories
- **Growth potential**: 30% in Potential Loyal segment represents conversion opportunity
- **Churn risk**: 21% (Need Attention + At Risk) require retention efforts

---

## Business Value

### Strategic Applications
- **Targeted marketing campaigns** - customize messaging per segment
- **Customer retention** - identify at-risk customers for re-engagement
- **Resource allocation** - prioritize high-value customer relationships
- **Growth opportunities** - convert potential loyals to loyal customers
- **Churn prevention** - proactive outreach to at-risk segment

### Segment-Specific Strategies
- **Best Customers**: VIP treatment, exclusive offers, loyalty rewards
- **Loyal Customers**: maintain engagement, upsell opportunities
- **Potential Loyal**: incentivize repeat purchases, build relationship
- **Need Attention**: win-back campaigns, personalized outreach
- **At Risk**: urgent intervention, special discounts, feedback gathering

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
