-- Data Cleaning Project
-- KAGGLE DATASET
-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

SELECT * 
FROM layoffs_raw;

-- Creating a staging table in case of data interruption in database
CREATE TABLE layoffs_staging 
LIKE layoffs_raw;

INSERT INTO layoffs_staging 
SELECT * FROM layoffs_raw;

SELECT *
FROM layoffs_staging;

-- Searching for duplicate values.
-- If the number of rows is bigger than 1 it means there are two or more exact rows with similar values in columns
WITH duplicate_cte AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Double checking if the values found were duplicates
SELECT *
FROM layoffs_staging
WHERE company = 'Casper' OR company = 'Yahoo'
ORDER BY company;

-- Creating another table so we can create row_num column and insert values of row_number
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

-- Inserting values from layoffs_staging to newly created table
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Deleting duplicate values
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- Since we got rid of duplicates we won't need row_num anymore
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Standarizing data
-- Triming spaces in text
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Fixing the names of certain rows in industry column
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY location;

-- Checking country column for mistakes
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

-- Fixing United States country value having additional dot
SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%' 
ORDER BY country;

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Changing date_format of `date` column from mm/dd/yyyy to yyyy/mm/dd
SELECT `date`
FROM layoffs_staging2;

SELECT `date`, date_format(str_to_date(`date`, '%m/%d/%Y'), '%d/%m/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = date_format('%d/%m/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Fixing the blank spaces from columns
SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Carvana';

-- Certain companies like Carvana have industry column not filled properly. 
-- For example Carvana appears two times. 
-- In one row Carvana has the industry filled and for the other row the value is blank.
-- We're going to fill those blank or null cells with the values from other rows.
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 
	ON t1.company = t2.company
	AND t1.location = t2.location
WHERE t1.industry IS NULL OR t1.industry = ''
AND t2.industry IS NOT NULL;

SELECT t1.industry,t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

-- For this company the industry row couldn't be filled because there wasn't any row with industry other than blank or null
SELECT *
FROM layoffs_staging2
WHERE company = "Bally's Interactive";

-- For those companies if both total_laid_off and percentage_laid_off is null that means we don't know if there were any layoffs.
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL





