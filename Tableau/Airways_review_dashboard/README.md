# British Airways Review Dashboard - Tableau

## Overview

Interactive Tableau dashboard analyzing customer satisfaction and service quality for British Airways based on 1,324 verified passenger reviews.  
The project provides comprehensive insights into flight experience across multiple dimensions including aircraft types, traveler segments, routes, and service categories spanning 2015-2023.

---

## Dataset Scope

### Review Coverage
- **1,324 passenger reviews** from British Airways flights
- **Time period**: 2015-2023 (9 years)
- **Global reach**: 251 countries represented
- **150+ aircraft types** including Boeing and Airbus models
- **19 attributes** per review including ratings, demographics, and feedback

### Rating Dimensions
- **Overall Rating**: 1-10 scale (average: 4.2)
- **Seat Comfort**: Passenger comfort assessment
- **Cabin Staff Service**: Crew interaction quality (average: 3.3)
- **Food & Beverages**: Meal service quality (average: 2.4)
- **Ground Service**: Airport and check-in experience (average: 3.0)
- **Entertainment**: In-flight entertainment system (average: 1.4)
- **Value For Money**: Price-to-service ratio (average: 2.8)

### Customer Segments
- **Traveller Types**: Couple Leisure (34%), Solo Leisure (29%), Business (24%), Family Leisure (13%)
- **Seat Classes**: Economy (46%), Business (38%), Premium Economy (10%), First Class (7%)
- **Trip Verification**: Mix of verified and unverified reviews

### Aircraft Fleet Coverage
Top aircraft by review volume:
- A320 (263 reviews)
- Boeing 777 (177 reviews)
- A380 (124 reviews)
- Boeing 747-400 (97 reviews)
- Boeing 777-200 (80 reviews)

---

## Key Features

### Metric Selection & Overview
- **Interactive metric picker** - radio button selection for focused analysis
- **7 key performance indicators** displayed prominently:
  - Average Rating (4.2)
  - Avg. Cabin Staff Service (3.3)
  - Avg. Entertainment (1.4)
  - Avg. Food & Beverages (2.4)
  - Avg. Ground Service (3.0)
  - Avg. Seat Comfort (2.9)
  - Avg. Value For Money (2.8)

### Temporal Analysis
- **Average Overall Rating By Month** - line chart tracking satisfaction trends from 2017-2023
- **Date range slider** - filter reviews by specific time periods (March 2016 - October 2023)
- **Trend identification** - visualize seasonal patterns and long-term service quality changes

### Geographic Analysis
- **Interactive world map** - choropleth visualization showing average ratings by country
- **Color-coded performance** - darker shades indicate better/worse ratings
- **Global coverage** - insights from 251 countries
- **Continent filter** - drill down by geographic region

### Aircraft Performance
- **Average Overall Rating By Aircraft** - dual-axis bar chart
  - Orange bars: Average rating per aircraft model
  - Teal bars: Number of reviews per aircraft type
- **Fleet comparison** - Boeing vs. Airbus performance
- **Aircraft filter** - analyze specific models

### Advanced Filtering
- **Traveller Type** - filter by Couple Leisure, Solo Leisure, Business, Family Leisure
- **Seat Type** - filter by Economy, Business, Premium Economy, First Class
- **Aircraft selection** - dropdown for specific aircraft models
- **Continent selection** - geographic filtering

---

## Technical Implementation

### Data Architecture
- **Primary dataset**: ba_reviews.csv (1,324 rows, 19 columns)
- **Supporting dataset**: Countries.csv (251 countries with continent/region mapping)
- **Data blending**: Join on country field for geographic visualization

### Tableau Features Used
- **Parameters** - metric selection toggle
- **Calculated fields** - average rating computations by dimension
- **Map visualization** - geographic bubble/choropleth map with Mapbox integration
- **Line chart** - temporal trend analysis with date aggregation
- **Dual-axis bar chart** - rating vs. review count comparison
- **Filters** - multiple dimension slicers (date, traveler type, seat class, aircraft)
- **Actions** - cross-filtering between visualizations
- **Dashboard layout** - responsive design with organized sections

### Design Elements
- **Color scheme**: Orange brand color for primary metrics, teal for supporting data
- **Typography**: Clear hierarchy with metric labels and values
- **Layout**: Organized into quadrants (metrics bar, temporal, geographic, aircraft analysis)
- **Interactivity**: Click-to-filter functionality across all charts

---

## Key Insights

### Overall Performance Metrics
- **Average rating 4.2/10**: Below-average customer satisfaction indicates service challenges
- **Entertainment lowest rated (1.4)**: Critical weakness requiring investment
- **Food quality concerns (2.4)**: Second-lowest metric, passenger dissatisfaction evident
- **Cabin staff highest rated (3.3)**: Relative strength compared to other metrics

### Aircraft-Specific Insights
- **Boeing 747-400 best rated (4.7)**: Older aircraft surprisingly performs well
- **A320 most reviewed (263)**: High volume workhorse of the fleet
- **Variability by model**: Significant rating differences across aircraft types
- **Review volume correlation**: Popular aircraft models accumulate more feedback

### Passenger Segment Patterns
- **Couple Leisure dominance**: Largest review segment (446 reviews)
- **Business travelers**: 24% of reviews - important premium segment
- **Economy class majority**: 46% of reviews from economy passengers
- **First class premium**: Only 7% of reviews but high-value segment

### Temporal Trends
- **2017-2023 tracking**: Multi-year performance monitoring available
- **Volatility visible**: Significant month-to-month rating fluctuations
- **Post-pandemic impact**: Data spans COVID-19 period, showing service evolution
- **Recent performance**: 2023 data shows current service quality trajectory

### Geographic Insights
- **Global coverage**: Reviews from all major markets
- **Regional variations**: Different satisfaction levels by country/continent
- **UK market focus**: Home market heavily represented in reviews
- **International routes**: Comprehensive coverage of long-haul destinations

---

## Business Value

### Service Quality Monitoring
- **Real-time feedback tracking** - monitor customer satisfaction across fleet
- **Trend identification** - detect service degradation or improvement patterns
- **Benchmark analysis** - compare performance across aircraft, routes, classes
- **Pain point detection** - identify specific areas requiring attention (entertainment, food)

### Strategic Decision Support
- **Fleet optimization** - retire or refurbish poorly-rated aircraft
- **Investment prioritization** - allocate resources to weakest service areas
- **Route planning** - understand satisfaction by destination/region
- **Product development** - improve entertainment and F&B offerings based on feedback

### Customer Experience Management
- **Segment-specific insights** - tailor improvements to traveler type needs
- **Class differentiation** - optimize service levels by seat class
- **Competitive positioning** - understand how BA performs in customer eyes
- **Loyalty impact** - address issues affecting repeat business

### Operational Applications
- **Crew training focus** - maintain cabin staff strength (3.3 rating)
- **Ground service improvements** - address check-in and airport experience gaps
- **Catering partnerships** - work with suppliers to improve food quality
- **Entertainment system upgrades** - critical investment area (1.4 rating)

---

## Tools & Technologies

- **Tableau Desktop** - dashboard development and data visualization
- **Mapbox** - geographic map integration for country-level analysis
- **Data sources**: CSV files (reviews and country metadata)
- **Calculated fields** - custom metrics and aggregations
- **Parameters & filters** - interactive dashboard functionality
- **Dashboard actions** - cross-filtering and drill-down capabilities

---

## Files Structure

- `Airways_Reviev.twbx` - Tableau packaged workbook containing:
  - Data connections (ba_reviews.csv, Countries.csv)
  - Dashboard layout and visualizations
  - Calculated fields and parameters
  - Interactive filters and actions
  - Map configuration (Mapbox)
- `ba_reviews.csv` - passenger review data (1,324 reviews, 19 attributes)
- `Countries.csv` - geographic reference data (251 countries with continent/region mapping)
- `AirwaysDash.png` - dashboard screenshot for documentation
