# Layoffs Data Cleaning - SQL Project

## Overview

Professional-grade data cleaning project using MySQL to transform raw layoffs data into analysis-ready format.  
The project demonstrates systematic data quality improvement through staging tables, duplicate removal, standardization, and strategic NULL handling while preserving data integrity.

---

## Dataset Scope

### Raw Data Profile
- **2,361 layoff records** from global companies
- **9 attributes** per record
- **Primary geographies**: United States (65%), India (6%), Canada (4%)
- **Industry coverage**: 32 sectors (Finance, Retail, Healthcare leading)
- **Company stages**: 16 funding stages (Post-IPO to Seed)
- **Time period**: Recent layoff events (2023 data visible)
- **60 countries** represented in dataset

### Data Quality Issues Identified
- ✗ **5 duplicate records**
- ✗ **740 missing** `total_laid_off` values (31%)
- ✗ **785 missing** `percentage_laid_off` values (33%)
- ✗ **209 missing** `funds_raised_millions` values (9%)
- ✗ **4 missing** `industry` values
- ✗ **Inconsistent industry naming** (Crypto vs. CryptoCurrency variants)
- ✗ **Location encoding errors** (Malmö → "Malm", Florianópolis → "Floria")
- ✗ **Country formatting issues** ("United States." with trailing period)
- ✗ **Date stored as TEXT** instead of DATE type
- ✗ **Leading/trailing whitespace** in company names

---

## Data Cleaning Methodology

### 1. Staging Table Strategy
**Problem**: Risk of irreversible data loss during cleaning  
**Solution**: Create staging table to preserve original data

```sql
-- Create exact replica of source table
CREATE TABLE layoffs_staging LIKE layoffs;

-- Copy all data to staging environment
INSERT INTO layoffs_staging SELECT * FROM layoffs;
```

**Benefits**:
- ✓ Original data remains untouched
- ✓ Ability to rollback if needed
- ✓ Safe experimentation environment

---

### 2. Duplicate Detection & Removal

#### Challenge: Identifying True Duplicates
Near-identical records may differ only in `funds_raised_millions`, requiring multi-column partitioning.

#### Solution: CTE with ROW_NUMBER()
```sql
WITH Duplicate_CTE AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, total_laid_off, 
                     percentage_laid_off, date, funds_raised_millions
    ) AS row_num
    FROM layoffs_staging
)
SELECT * FROM Duplicate_CTE WHERE row_num > 1;
```

#### MySQL Limitation Workaround
MySQL doesn't support DELETE operations on CTEs directly.

**Solution**: Create intermediate table with `row_num` as permanent column
```sql
-- Create table with row_num column
CREATE TABLE layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT DEFAULT NULL,
    percentage_laid_off TEXT,
    date TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT DEFAULT NULL,
    row_num INT
);

-- Insert with row numbers
INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER (...) AS row_num FROM layoffs_staging;

-- Delete duplicates
DELETE FROM layoffs_staging2 WHERE row_num > 1;

-- Drop temporary column
ALTER TABLE layoffs_staging2 DROP COLUMN row_num;
```

**Result**: 5 duplicate records removed

---

### 3. Data Standardization

#### 3A. Whitespace Removal
**Problem**: `company` column contains unnecessary leading/trailing spaces

```sql
-- Identify issues
SELECT DISTINCT company FROM layoffs_staging2;

-- Apply fix
UPDATE layoffs_staging2 SET company = TRIM(company);
```

#### 3B. Industry Normalization
**Problem**: Inconsistent cryptocurrency naming conventions
- "Crypto"
- "CryptoCurrency"  
- "Crypto Currency"

```sql
-- Standardize to single format
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%';
```

#### 3C. Location Corrections
**Problem**: UTF-8 encoding errors in city names

**Malmö encoding issue**:
```sql
UPDATE layoffs_staging2
SET location = 'Malmo'
WHERE company LIKE 'Oatly' AND location LIKE "%Malm%";
```

**Florianópolis encoding issue**:
```sql
UPDATE layoffs_staging2
SET location = 'Florianopolis'
WHERE company LIKE 'Involves' AND location LIKE "%Floria%";
```

#### 3D. Country Name Cleanup
**Problem**: "United States." has trailing period

```sql
UPDATE layoffs_staging2
SET Country = TRIM(TRAILING '.' FROM country)
WHERE Country LIKE 'United States%';
```

---

### 4. NULL Value Imputation

#### Industry Column Strategy
**Problem**: 4 missing industry values, but same companies may have industry elsewhere

**Solution**: Self-join to populate missing industries from matching companies
```sql
-- Convert blanks to NULL for consistency
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Populate from matching company records
UPDATE layoffs_staging2 t1 
JOIN layoffs_staging2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;
```

**Logic**: If Company X has industry "Finance" in row 5, apply "Finance" to row 12 where it's NULL.

---

### 5. Data Type Conversions

#### Date Column Transformation
**Problem**: Date stored as TEXT in `m/d/Y` format

**Solution**: Convert to proper DATE type
```sql
-- Parse text date to MySQL date format
UPDATE layoffs_staging2
SET date = STR_TO_DATE(date, '%m/%d/%Y');

-- Change column data type
ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;
```

**Result**: Proper date handling for temporal queries

---

### 6. Strategic Record Removal

#### Unusable Records
**Problem**: 740 records missing BOTH `total_laid_off` AND `percentage_laid_off`

**Analysis**: Records with no layoff metrics cannot provide value for layoff analysis

```sql
-- Identify unusable records
SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Remove
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
```

**Justification**: Without either metric, we cannot determine if/how many layoffs occurred

---

## Technical Implementation

### SQL Techniques Demonstrated

**Advanced Query Patterns**
- **Common Table Expressions (CTEs)**: Duplicate detection logic
- **Window Functions**: ROW_NUMBER() with PARTITION BY
- **Self-Joins**: Cross-referencing same table for data imputation
- **String Functions**: TRIM, TRIM(TRAILING), LIKE pattern matching
- **Date Functions**: STR_TO_DATE() for parsing
- **Schema Modification**: ALTER TABLE, MODIFY COLUMN

**Best Practices Applied**
- ✓ **Non-destructive workflow** (staging tables)
- ✓ **Incremental validation** (SELECT before UPDATE/DELETE)
- ✓ **Explicit column specification** (avoid SELECT *)
- ✓ **Descriptive naming** (layoffs_staging2 vs temp_table)
- ✓ **Commented code** explaining decisions
- ✓ **Systematic approach** (duplicates → standardization → nulls → types)

---

## Key Insights

### Data Quality Improvements

**Before Cleaning**
| Issue | Count |
|-------|-------|
| Total Records | 2,361 |
| Duplicates | 5 |
| Missing Industry | 4 |
| Whitespace Issues | Multiple |
| Encoding Errors | 2+ locations |
| Format Inconsistencies | Multiple industries |
| Wrong Data Types | 1 (date) |
| Unusable Records | 740 |

**After Cleaning**
| Metric | Result |
|--------|--------|
| Clean Records | ~1,616 |
| Duplicates | 0 |
| Standardized Industries | ✓ |
| Trimmed Text Fields | ✓ |
| Corrected Locations | ✓ |
| Proper Date Format | ✓ |
| Data Type Integrity | ✓ |

**Data Reduction**: 2,361 → ~1,616 records (31% removal justified by lack of metrics)

### Technical Insights
1. **MySQL CTE limitations**: Cannot DELETE from CTE; requires intermediate table workaround
2. **Self-join power**: Effective technique for imputing missing categorical values
3. **TRIM variations**: TRIM(TRAILING) for targeted whitespace removal
4. **STR_TO_DATE importance**: Critical for converting text dates to queryable DATE type

### Data Quality Insights
1. **31% records lacked metrics**: Highlights importance of data collection standards
2. **Encoding errors localized**: UTF-8 issues primarily in non-English city names
3. **Industry naming chaos**: Lack of data entry standards creates cleanup overhead
4. **Duplicate sources**: Near-identical records suggest potential ETL issues

---

## Business Value

### Analysis-Ready Dataset
- **Temporal analysis**: Proper DATE type enables time-series queries
- **Industry insights**: Standardized categories enable grouping/aggregation
- **Geographic analysis**: Clean country/location data for regional breakdowns
- **Funding correlation**: Relate layoffs to company funding stage

### Use Cases Enabled
- **Layoff trend analysis**: Track patterns by industry/country/time
- **Company stage analysis**: Compare layoffs by funding stage
- **Severity assessment**: Analyze percentage_laid_off distributions
- **Economic indicators**: Aggregate data for macro insights

### Data Integrity
- **Reliable aggregations**: No duplicate inflation of metrics
- **Accurate joins**: Clean company/location names for integration
- **Consistent reporting**: Standardized categories across analyses

---

## Tools & Technologies

- **Database**: MySQL
- **SQL Version**: Compatible with MySQL 8.0+ (window functions)
- **Encoding**: UTF8MB4
- **Collation**: utf8mb4_0900_ai_ci

---

## Files Structure

- `Layoffs_raw.csv` - original dataset (2,361 records, 9 attributes)
- `layoffs_cleaning_queries.sql` - complete cleaning script with:
  - Staging table creation
  - Duplicate removal logic
  - Standardization queries
  - NULL handling procedures
  - Data type conversions
  - Inline documentation

---

## Future Enhancement Opportunities

- **Automated validation**: Create stored procedures for ongoing data ingestion
- **Audit logging**: Track changes made during cleaning process
- **Data quality metrics**: Calculate quality scores pre/post cleaning
- **Constraint addition**: Add foreign keys, check constraints post-cleaning
- **View creation**: Build analysis-ready views on cleaned data
- **Index optimization**: Add indexes on commonly queried columns (industry, country, date)
