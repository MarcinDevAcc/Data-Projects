# British Airways Review Dashboard - Tableau

## Overview

Interactive Tableau dashboard analyzing British Airways passenger reviews and service ratings across multiple dimensions including aircraft types, traveler segments, geographic regions, and service categories.

The project is based on **1,324 passenger reviews** covering the period **2015-2023**.

---

## Dataset Scope

### Review Coverage
- **1,324 passenger reviews**
- **Time period**: 2015-2023
- **19 attributes** per review including ratings, traveler information, and flight details
- **150+ aircraft types** represented in the review dataset
- **Geographic reference data**: 251 countries available for continent and region mapping

### Rating Dimensions
- **Overall Rating**: 1-10 scale (average: 4.2)
- **Seat Comfort**: average 2.9
- **Cabin Staff Service**: average 3.3
- **Food & Beverages**: average 2.4
- **Ground Service**: average 3.0
- **Entertainment**: average 1.4
- **Value For Money**: average 2.8

### Customer Segments
- **Traveller Types**:
  - Couple Leisure — 34%
  - Solo Leisure — 29%
  - Business — 24%
  - Family Leisure — 13%
- **Seat Classes**:
  - Economy — 46%
  - Business — 38%
  - Premium Economy — 10%
  - First Class — 7%
- **Trip Verification**: Dataset includes both verified and unverified reviews

### Aircraft Review Coverage
Top aircraft by review volume:
- A320 — 263 reviews
- Boeing 777 — 177 reviews
- A380 — 124 reviews
- Boeing 747-400 — 97 reviews
- Boeing 777-200 — 80 reviews

---

## Key Features

### Metric Selection & Overview
- **Interactive metric picker** using Tableau parameters
- **7 key metrics** displayed:
  - Average Rating — 4.2
  - Avg. Cabin Staff Service — 3.3
  - Avg. Entertainment — 1.4
  - Avg. Food & Beverages — 2.4
  - Avg. Ground Service — 3.0
  - Avg. Seat Comfort — 2.9
  - Avg. Value For Money — 2.8

### Temporal Analysis
- **Average Overall Rating by Month**
- **Date range slider** for filtering selected review periods
- Monthly rating changes can be compared across the available time range

### Geographic Analysis
- **Interactive world map** showing average ratings by country
- Color intensity represents average rating
- **Continent filter** for regional comparison
- Review data enriched with geographic metadata from the supporting country table

### Aircraft Performance
- **Average Overall Rating by Aircraft**
- Dual-axis comparison of:
  - average rating
  - review count
- Aircraft-specific filtering
- Boeing and Airbus models can be compared within the dashboard

### Interactive Filtering
- **Traveller Type**
- **Seat Class**
- **Aircraft**
- **Continent**
- **Date range**
- Dashboard actions support cross-filtering between visualizations

---

## Technical Implementation

### Data Architecture
- **Primary dataset**: `ba_reviews.csv` — 1,324 rows, 19 columns
- **Supporting dataset**: `Countries.csv` — geographic reference table with 251 countries
- **Data join**: review data enriched with continent and region information using the country field

### Tableau Features Used
- **Parameters** — metric selection
- **Calculated fields** — rating aggregations
- **Map visualization** — country-level geographic analysis
- **Line chart** — temporal analysis
- **Dual-axis chart** — rating vs review count comparison
- **Filters** — date, traveler type, seat class, aircraft, continent
- **Dashboard actions** — cross-filtering between visuals
- **Dashboard layout** — organized single-dashboard presentation

### Design Elements
- Brand-oriented orange accent for primary metrics
- Supporting teal color for secondary values
- Clear metric hierarchy
- Structured layout separating:
  - KPI overview
  - temporal analysis
  - geographic analysis
  - aircraft analysis

---

## Key Insights

### Service Ratings
- **Average overall rating**: 4.2/10
- **Entertainment** is the lowest-rated service dimension at **1.4**
- **Food & Beverages** is the second-lowest service metric at **2.4**
- **Cabin Staff Service** is the highest-rated displayed service dimension at **3.3**

### Aircraft Analysis
- **Boeing 747-400** has the highest displayed average rating at **4.7**
- **A320** has the highest review count with **263 reviews**
- Average ratings vary across aircraft models
- Review volume also differs substantially between aircraft types

### Passenger Segments
- **Couple Leisure** is the largest traveler group at **34%**
- **Business travelers** account for **24%** of reviews
- **Economy Class** represents **46%** of reviews
- **First Class** represents **7%** of reviews

### Temporal Analysis
- Ratings can be compared across the available multi-year review period
- Monthly average ratings fluctuate over time
- 2023 contains the most recent observations available in the dataset

### Geographic Analysis
- Ratings can be compared across countries represented in the review data
- Continent-level filtering enables broader regional comparison
- Geographic metadata is provided through the supporting country reference table

---

## Business / Analytical Value

- **Service comparison** — compare customer ratings across service dimensions
- **Aircraft analysis** — compare average ratings and review volume by aircraft type
- **Passenger segmentation** — analyze reviews by traveler type and seat class
- **Temporal analysis** — monitor rating changes across the available review period
- **Geographic comparison** — compare ratings across countries and regions represented in the dataset

---

## Tools & Technologies

- **Tableau Desktop** — dashboard development and visualization
- **Mapbox** — geographic map integration
- **CSV data sources** — reviews and country metadata
- **Calculated fields** — custom aggregations
- **Parameters & filters** — dashboard interactivity
- **Dashboard actions** — cross-filtering between views

---

## Files Structure

- `Airways_Reviev.twbx` — Tableau packaged workbook containing:
  - data connections
  - dashboard layout and visualizations
  - calculated fields and parameters
  - interactive filters and actions
  - map configuration
- `ba_reviews.csv` — passenger review data (1,324 reviews, 19 attributes)
- `Countries.csv` — geographic reference data (251 countries)
- `AirwaysDash.png` — dashboard screenshot for documentation
