# Ultra Marathon Running - Exploratory Data Analysis (Python)

## Overview

Data cleaning and exploratory analysis project focusing on 100km ultra-marathon races held in Poland between 2010-2018.  
The project processes a massive historical dataset (7.4 million race results spanning two centuries) and extracts actionable insights about Polish ultra-running performance patterns.

Dataset source: [Kaggle - The Big Dataset of Ultra Marathon Running](https://www.kaggle.com/datasets/aiaiaidavid/the-big-dataset-of-ultra-marathon-running)

---

## Dataset Scope

### Raw Dataset Characteristics
- **7,461,195 race results** from global ultra-marathon events
- **Time span**: Two centuries of ultra-running history
- **13 attributes** per race result
- **246 MB compressed** data file

### Filtered Analysis Dataset
- **Focus**: 100km races in Poland (2010-2018)
- **9,351 race results** after filtering
- **Geographic scope**: Polish ultra-marathon events only
- **Distance**: Standardized 100km races

### Key Metrics Tracked
- Event year and dates
- Race name and location
- Race distance/length
- Number of finishers per event
- Athlete performance (completion time)
- Athlete demographics (gender, age, birth year)
- Athlete average speed (km/h)
- Unique athlete identifiers

---

## Data Processing Pipeline

### 1. Data Acquisition
- **Kaggle API integration** for automated dataset download
- **ZIP file extraction** (246 MB compressed archive)
- **CSV parsing** with mixed-type column handling

### 2. Filtering & Scoping
- **Geographic filter**: Extract only Polish events `(POL)`
- **Distance filter**: Focus on 100km races
- **Temporal filter**: Events from 2010 onwards
- **Result**: 9,351 relevant race results from 7.4M+ records

### 3. Data Cleaning Operations

#### Text Normalization
- **Event name cleaning**: Remove `(POL)` country suffix
- **String standardization**: Strip whitespace and formatting artifacts

#### Feature Engineering
- **Age calculation**: Derive athlete age from birth year (2025 reference)
- **Formula**: `athlete_age = 2025 - Athlete year of birth`

#### Data Type Conversions
- **Time string parsing**: Convert performance times from strings
- **Speed normalization**: Handle mixed format in `Athlete average speed` column
- **Date formatting**: Standardize race date formats

#### Data Quality Fixes
- **Null value handling**: 488 missing ages dropped
- **Outlier removal**: Athletes with speed >50 km/h removed (data quality issues)
- **Format errors**: Rows with time strings in speed column dropped

#### Column Management
- **Dropped columns**: Athlete club, country, birth year, age category (redundant/unnecessary)
- **Renamed columns**: Standardized naming convention (snake_case)
- **Final schema**: 10 clean columns

### 4. Final Dataset Structure
```
Columns (10):
- event_year
- race_day
- race_name
- race_length
- race_number_of_finishers
- athlete_performance
- athlete_gender
- athlete_average_speed
- athlete_id
- athlete_age
```

---

## Exploratory Data Analysis

### Distribution Analysis
- **Athlete average speed distribution** (100km races)
  - Visualization: seaborn displot
  - Insights into performance patterns and typical completion paces

### Gender Comparison
- **Race participation by gender**
  - Histogram with gender-based hue
  - Understanding male vs. female representation in ultra-running

### Performance Patterns
- **Completion time analysis** across different events
- **Speed consistency** examination within 100km category
- **Age vs. performance** relationship exploration

---

## Key Insights

### Data Quality Findings
- **High-quality subset**: After cleaning, 9,351 valid race results
- **Age data completeness**: ~95% of records have valid age information
- **Speed anomalies**: Some records required outlier removal for realistic analysis

### Event Characteristics
- **Polish ultra-marathon scene**: Multiple recurring 100km events tracked
- **Notable events**: 
  - Setka Komandosa (Lubliniec - Kokotek)
  - Bieg 7 dolin - 100 km Ultramaraton
  - And others

### Athlete Demographics
- **Age range**: Broad participation from 20s to 70+
- **Gender distribution**: Detailed tracking available for diversity analysis
- **Performance metrics**: Speed ranges from ~6 km/h (slower finishers) to 11+ km/h (elite performers)

---

## Technical Implementation

### Data Processing Stack
- **pandas** - data manipulation, filtering, cleaning
- **numpy** - numerical operations (implicit)

### Visualization Libraries
- **seaborn** - statistical graphics (distribution plots, histograms)
- **matplotlib** - underlying plotting framework

### Data Pipeline Tools
- **kaggle API** - automated dataset retrieval
- **zipfile** - archive extraction
- **Python standard library** - string operations, datetime handling

### Notebook Environment
- **Jupyter Notebook** - interactive analysis
- **Python 3.12** - programming language

---

## Data Cleaning Challenges Solved

### Challenge 1: Mixed Data Types
**Problem**: `Athlete average speed` column contained both numeric values and time strings  
**Solution**: Identified and dropped rows with time-format strings, converted to float

### Challenge 2: Outlier Speeds
**Problem**: Some speed values >50 km/h (unrealistic for 100km races)  
**Solution**: Applied upper threshold filter for data quality

### Challenge 3: Null Age Values
**Problem**: 488 records missing athlete birth year  
**Solution**: Dropped incomplete records after age calculation

### Challenge 4: Event Name Formatting
**Problem**: All event names contained redundant `(POL)` suffix  
**Solution**: Regex-based string replacement and stripping

### Challenge 5: Date Format Inconsistency
**Problem**: Various date formats in raw data  
**Solution**: Standardized date parsing and conversion

---

## Applications & Use Cases

### Sports Analytics
- **Performance benchmarking**: Compare athlete times against event averages
- **Training insights**: Understand typical 100km completion paces
- **Event analysis**: Identify most competitive/popular races

### Event Planning
- **Participation trends**: Track growth of ultra-running in Poland
- **Capacity planning**: Analyze finisher counts for event sizing
- **Calendar optimization**: Identify event clustering and timing patterns

### Research & Academia
- **Endurance sports science**: Age vs. performance relationships
- **Gender studies**: Male/female participation and performance gaps
- **Longitudinal analysis**: Year-over-year performance trends (2010-2018)

### Athlete Development
- **Goal setting**: Realistic completion time targets based on age/gender
- **Progress tracking**: Compare personal results against historical data
- **Competition selection**: Choose events based on field strength

---

## Reproducibility

The analysis is fully reproducible:
1. **Automated data download** via Kaggle API (requires API credentials)
2. **Sequential notebook execution** processes entire pipeline
3. **No manual data intervention** required
4. **All cleaning steps documented** with inline comments

---

## Files Structure

- `Exploratory_Data_Analysis_ultra_marathon_running_dataset.ipynb` - complete data processing and EDA notebook
- Source data: `TWO_CENTURIES_OF_UM_RACES.csv` (downloaded via Kaggle API, not included in repo)
