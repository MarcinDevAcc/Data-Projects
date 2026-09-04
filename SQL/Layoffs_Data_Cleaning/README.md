# Layoffs Data Cleaning - SQL Project

## Overview

SQL data-cleaning project using MySQL to transform raw layoffs data into an analysis-ready dataset.

The project applies a structured cleaning workflow using staging tables, duplicate detection, text standardization, NULL handling, and data type conversion while preserving the original source table.

---

## Dataset Scope

### Raw Data Profile
- **2,361 layoff records**
- **9 attributes** per record
- **Primary geographies**: United States (65%), India (6%), Canada (4%)
- **Industry coverage**: 32 sectors
- **Company stages**: 16 funding stages
- **60 countries** represented
- 2023 records are included in the source data

### Data Quality Issues Identified
- **5 duplicate records**
- **740 missing** `total_laid_off` values
- **785 missing** `percentage_laid_off` values
- **209 missing** `funds_raised_millions` values
- **4 missing** `industry` values
- Inconsistent industry naming
- Malformed location values
- Country formatting inconsistencies
- Date stored as `TEXT`
- Leading / trailing whitespace in company names

---

## Data Cleaning Methodology

### 1. Staging Table Strategy

**Problem**: Cleaning the source table directly risks irreversible changes.

**Solution**: Create a working copy and preserve the original dataset.

```sql
CREATE TABLE layoffs_staging LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;
```

**Result**
- Original source table remains untouched
- Cleaning can be performed safely in staging
- Intermediate results can be validated before destructive operations

---

### 2. Duplicate Detection & Removal

#### Problem

Near-identical records may only become identifiable when multiple business fields are compared together.

#### Solution

Use `ROW_NUMBER()` with `PARTITION BY` to identify duplicates.

```sql
WITH Duplicate_CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company,
                            location,
                            total_laid_off,
                            percentage_laid_off,
                            date,
                            funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM Duplicate_CTE
WHERE row_num > 1;
```

#### MySQL Workaround

Because duplicate rows cannot be deleted directly from the CTE result, an intermediate staging table with a persistent `row_num` column is used.

```sql
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

INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER (...) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
```

**Result**: 5 duplicate records removed.

---

### 3. Data Standardization

#### Company Name Cleanup

**Problem**: Company names contain unnecessary leading or trailing whitespace.

```sql
UPDATE layoffs_staging2
SET company = TRIM(company);
```

---

#### Industry Normalization

**Problem**: Cryptocurrency companies use multiple category labels:
- `Crypto`
- `CryptoCurrency`
- `Crypto Currency`

```sql
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%';
```

---

#### Location Corrections

**Problem**: Some city values are malformed in the source data.

Examples:
- Malmö represented as a truncated / malformed value
- Florianópolis represented as a truncated / malformed value

```sql
UPDATE layoffs_staging2
SET location = 'Malmo'
WHERE company LIKE 'Oatly'
  AND location LIKE '%Malm%';

UPDATE layoffs_staging2
SET location = 'Florianopolis'
WHERE company LIKE 'Involves'
  AND location LIKE '%Floria%';
```

---

#### Country Name Cleanup

**Problem**: `United States.` contains a trailing period.

```sql
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
```

---

### 4. NULL Value Handling

#### Industry Imputation

**Problem**: Four rows have missing industry values, while the same companies have populated industry values elsewhere in the dataset.

**Solution**: Use a self-join to populate the missing category from another row belonging to the same company.

```sql
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;
```

This approach reuses information already present in the dataset instead of assigning a new category manually.

---

### 5. Data Type Conversion

#### Date Column

**Problem**: Date values are stored as `TEXT`.

**Solution**: Parse the source format and convert the column to `DATE`.

```sql
UPDATE layoffs_staging2
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;
```

**Result**: Date values can be used reliably in temporal queries.

---

### 6. Remove Unusable Records

**Problem**: 740 records are missing both:
- `total_laid_off`
- `percentage_laid_off`

Without either metric, the records cannot support analysis of layoff volume or severity.

```sql
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;
```

---

## SQL Techniques Demonstrated

- **Common Table Expressions (CTEs)** — duplicate detection
- **Window Functions** — `ROW_NUMBER()` with `PARTITION BY`
- **Self-Joins** — filling missing categorical values from matching company records
- **String Functions** — `TRIM`, `TRIM(TRAILING)`, `LIKE`
- **Date Functions** — `STR_TO_DATE()`
- **Schema Modification** — `ALTER TABLE`, `MODIFY COLUMN`
- **Staging Tables** — non-destructive cleaning workflow
- **Incremental validation** — inspection before `UPDATE` and `DELETE`

---

## Cleaning Results

### Before Cleaning

| Issue | Count |
|---|---:|
| Total records | 2,361 |
| Duplicate records | 5 |
| Missing industry | 4 |
| Missing `total_laid_off` | 740 |
| Missing `percentage_laid_off` | 785 |
| Missing `funds_raised_millions` | 209 |
| Wrong date type | 1 column |
| Category / text inconsistencies | Multiple |

### After Cleaning

| Metric | Result |
|---|---|
| Final records | 1,616 |
| Duplicate records | 0 |
| Industry labels | Standardized |
| Company names | Trimmed |
| Selected malformed locations | Corrected |
| Country formatting | Standardized |
| Date column | Converted to `DATE` |

**Final dataset**: 2,361 → 1,616 records  
- 5 duplicate records removed
- 740 records excluded because both layoff metrics were missing

---

## Key Technical Insights

1. **Window functions provide a reliable way to detect duplicate records across multiple fields.**

2. **Self-joins can recover missing categorical values when the same entity appears elsewhere with complete information.**

3. **Converting dates from `TEXT` to `DATE` is necessary for reliable filtering, grouping, and temporal analysis.**

4. **Staging tables allow destructive cleaning operations without modifying the original dataset.**

---

## Data Quality Findings

- Five duplicate records were identified and removed
- Four missing industry values could be recovered from matching company records
- Multiple cryptocurrency labels required standardization
- Selected city values required manual correction
- 740 records lacked both layoff-volume metrics and were excluded from the analysis-ready dataset

---

## Business / Analytical Value

- **Temporal analysis** — proper `DATE` values enable time-based queries
- **Industry analysis** — standardized categories support reliable grouping
- **Geographic analysis** — cleaned country and location values improve regional comparisons
- **Reliable aggregation** — duplicate removal prevents double counting
- **Severity analysis** — retained records contain at least one usable layoff metric

---

## Tools & Technologies

- **Database**: MySQL
- **Compatibility**: MySQL 8.0+
- **Encoding**: UTF8MB4
- **Collation**: `utf8mb4_0900_ai_ci`

---

## Files Structure

- `Layoffs_raw.csv` — original dataset (2,361 records, 9 attributes)
- `layoffs_cleaning_queries.sql` — complete cleaning script containing:
  - staging table creation
  - duplicate detection and removal
  - text standardization
  - NULL handling
  - data type conversion
  - record filtering
  - inline documentation

---

## Future Enhancement Opportunities

- **Automated validation** — stored procedures for repeated ingestion checks
- **Audit logging** — record cleaning actions and row-count changes
- **Data-quality metrics** — calculate pre/post cleaning quality indicators
- **Constraints** — add appropriate validation constraints after cleaning
- **Views** — create analysis-ready views
- **Indexing** — optimize commonly filtered columns such as `industry`, `country`, and `date`
