# Plant Co. Performance Dashboard - Power BI

## Overview

Interactive Power BI dashboard built on a fictional Plant Company sales dataset.  
The project analyzes quantity sold, sales revenue, and gross profit across countries, product types, and time periods — with a focus on Year-to-Date (YTD) vs Prior Year-to-Date (PYTD) performance comparison.

---

## Key Features

### Dynamic Metric Switching
- Single slicer to switch between three core metrics: **Sales**, **Quantity**, **Gross Profit**
- All visuals, titles, and KPI cards update dynamically based on selection
- Implemented via DAX `SWITCH()` measures (`S_YTD`, `S_PYTD`)

### Core KPI Cards
- **PYTD** — Prior Year to Date value
- **YTD vs PYTD** — absolute change year-over-year
- **YTD** — Year to Date value
- **GP%** — Gross Profit margin

### Bottom 10 Countries (Treemap)
- Identifies worst-performing markets by YTD vs PYTD delta
- Quick visual triage of underperforming regions

### Waterfall Chart — YTD vs PYTD by Month, Country, Product
- Month-by-month breakdown of increases and decreases vs prior year
- Drill-down capability: Month → Country → Product

### Stacked Bar + Line Chart — YTD & PYTD by Month
- Sales/Quantity/Profit split by product type: **Indoor**, **Landscape**, **Outdoor**
- Overlaid PYTD line for direct period comparison

### Scatter Plot — Account Profitability Segmentation
- Each point represents a customer account
- Axes: GP% (profitability) vs Value YTD (volume)
- Reference lines at average GP% and quantity threshold for quadrant analysis

---

## Data Preparation (Power Query)

Basic data cleaning applied before loading into the model:

- Column renaming for consistency across tables
- Data type validation
- Duplicate check and removal

---

## Data Model

Star schema with one fact table and three dimension tables:

| Table | Type | Key Columns |
|---|---|---|
| `Fact_Sales` | Fact | Account_id, Product_id, Date_Time, Sales_USD, COGS_USD, quantity |
| `Dim_Date` | Dimension | Date, Inpast |
| `Dim_Product` | Dimension | Product_Name, Product_Family, Product_Group, Produt_Type, Product_Size |
| `Dim_Account` | Dimension | Account, country, latitude, longitude |
| `Slc_Values` | Helper | Values (slicer for metric selection) |
| `_Measures` | Measures table | All DAX measures |

---

## DAX Measures

### Base Measures
```dax
Sales = SUM(Fact_Sales[Sales_USD])
COGs = SUM(Fact_Sales[COGS_USD])
Gross Profit = [Sales] - [COGs]
Quantity = SUM(Fact_Sales[quantity])
GP% = DIVIDE([Gross Profit], [Sales])
```

### Year-to-Date (YTD)
```dax
YTD_Sales = TOTALYTD([Sales], Fact_Sales[Date_Time])
YTD_Quantity = TOTALYTD([Quantity], Fact_Sales[Date_Time])
YTD_GrossProfit = TOTALYTD([Gross Profit], Fact_Sales[Date_Time])
```

### Prior Year-to-Date (PYTD)
```dax
PYTD_Sales = 
CALCULATE(
    [Sales],
    SAMEPERIODLASTYEAR(Dim_Date[Date]),
    Dim_Date[Inpast] = TRUE
)
```
*(analogous measures for Quantity and Gross Profit)*

### Dynamic Switch Measures
```dax
S_YTD = 
VAR selected_value = SELECTEDVALUE(Slc_Values[Values])
RETURN SWITCH(selected_value,
    "Sales",        [YTD_Sales],
    "Quantity",     [YTD_Quantity],
    "Gross Profit", [YTD_GrossProfit]
)

YTD vs PYTD = [S_YTD] - [S_PYTD]
```

### Dynamic Titles
```dax
_Report title = 
"Plant Co. " & SELECTEDVALUE(Slc_Values[Values]) & " Perf. for " 
& SELECTEDVALUE(Dim_Date[Date].[Rok])
```

---

## Interactivity

- Switch between Sales / Quantity / Gross Profit with a single click
- Filter by year
- Cross-filter across all visuals
- Drill down in waterfall chart by Month → Country → Product

---

## Business Value

- Year-over-year performance monitoring across all key metrics
- Identification of underperforming markets (Bottom 10 treemap)
- Customer profitability segmentation for account management
- Product type contribution analysis over time

---

## Tools

- Power BI Desktop
- DAX (Data Analysis Expressions)
- Star schema data modeling
- Time intelligence functions (`TOTALYTD`, `SAMEPERIODLASTYEAR`)
