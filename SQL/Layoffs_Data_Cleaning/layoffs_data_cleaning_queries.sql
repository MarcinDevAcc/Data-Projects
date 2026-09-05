-- Layoffs Data Cleaning

SELECT * 
FROM layoffs;

-- Lets start by adding staging column and removing duplicates
-- Staging column ensures that original data wont be changes in any way in case we need it

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT * 
FROM layoffs;

SELECT * 
FROM layoffs_staging;

-- All data from layoffs data has been successfully exported to staging table

-- We can move on to removing duplicates 
-- We will use CTE to count row_number of rows
-- If row_number is two or greater that there are two identical rows
-- I've added column funds_raised_millions, because some companies had nearly identical data and the only differ was data in this column

WITH Duplicate_CTE AS(
SELECT *,
ROW_NUMBER() OVER
(PARTITION BY company,location,total_laid_off,percentage_laid_off,`date`,funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM Duplicate_CTE
WHERE row_num > 1;

-- Unfortunately, MySQL does not allow to just DELETE from CTE
-- We will create another table, with row_num as already existing column, not a query result

CREATE TABLE `layoffs_staging2` (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL,
    `row_num` INT
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI;

SELECT *
FROM layoffs_staging2;

-- We want to insert data with row_num
-- To do so, we are going to use the part of existing query we used before

-- This query is located in Duplicate_CTE

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER
(PARTITION BY company,location,total_laid_off,percentage_laid_off,`date`,funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- We successfully got rid of all duplicates (rows with row_num greater than 1)
-- With that row_num is no longer needed, so we can drop that column

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Now, we will standardize data
-- Data standardization is the process of transforming data to ensure it follows a consistent format and scale across all entries.
-- Lets start by trimming company name, as it contains unnecesarry spaces

SELECT DISTINCT company
FROM layoffs_staging2;

SELECT TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);



-- Now we are going to check industry column
-- Lets start by setting CryptoCurrency columns to Crypto

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE '%Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%';

-- Lets fill up nulls and empty cells in industry column
-- First, we will replace blanks with nulls

SELECT *
FROM layoffs_staging2
WHERE industry LIKE ''
OR industry IS NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- We will join table on itself, so we can compare values from one table to another to populate missing industry
-- with industry from same company where industry is actually null

SELECT *
FROM layoffs_staging2 t1 JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1 JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


-- Now, we will fix some cells in location table which have not been translated properly

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE location LIKE "%Malm%";

UPDATE layoffs_staging2
SET location = 'Malmo'
WHERE company LIKE 'Oatly'
AND location LIKE "%Malm%";

SELECT *
FROM layoffs_staging2
WHERE location LIKE "%Floria%";

UPDATE layoffs_staging2
SET location = 'Florianopolis'
WHERE company LIKE 'Involves'
AND location LIKE "%Floria%";


-- Lets now look at country column

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- There is one cell with additional dot at the end 'United States.'
-- To fix this, we can use Trim(TRAILING '')
-- TRAILING inside TRIM specifies what to remove from the string

UPDATE layoffs_staging2
SET Country = TRIM(TRAILING '.' FROM country)
WHERE Country LIKE 'United States%';

-- After cleaning country column, we will check `date` column
-- When we imported dataset, we did not change datatype of any column
-- `date` column stayed as a string, which we don't want to have in our table
-- Additionally, we want `date` column to have proper date format

SELECT `date`
FROM layoffs_staging2
ORDER BY 1;

-- Change the date format of date column to mm/dd/yyyy which is default MySQL date format
UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

-- And at the end, change modify column to DATE datatype
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- We will not need nulls in total_laid_off and percentage_laid_off as w eon't know if they had any layoffs.

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
