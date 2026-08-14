-- Layoffs Data Cleaning Project
-- MySQL
-- Expected source table: world_layoffs.layoffs
--
-- Workflow:
-- 1. Create a working copy
-- 2. Identify and remove true duplicate rows
-- 3. Standardize inconsistent values
-- 4. Inspect NULLs
-- 5. Remove records that contain no usable layoff information

USE world_layoffs;

-- ============================================================
-- 1. CREATE A STAGING COPY
-- ============================================================

DROP TABLE IF EXISTS layoffs_staging;

CREATE TABLE layoffs_staging LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- ============================================================
-- 2. CHECK FOR DUPLICATES
-- ============================================================

-- A partial duplicate check can reveal repeated combinations,
-- but similar-looking rows may represent separate layoff events.

SELECT company,
       industry,
       total_laid_off,
       `date`,
       ROW_NUMBER() OVER (
           PARTITION BY company, industry, total_laid_off, `date`
           ORDER BY company
       ) AS row_num
FROM layoffs_staging;

-- Check complete-row duplicates.
SELECT *
FROM (
    SELECT company,
           location,
           industry,
           total_laid_off,
           percentage_laid_off,
           `date`,
           stage,
           country,
           funds_raised_millions,
           ROW_NUMBER() OVER (
               PARTITION BY company,
                            location,
                            industry,
                            total_laid_off,
                            percentage_laid_off,
                            `date`,
                            stage,
                            country,
                            funds_raised_millions
               ORDER BY company
           ) AS row_num
    FROM layoffs_staging
) AS duplicate_check
WHERE row_num > 1;

-- Build a second staging table with duplicate rows numbered.
DROP TABLE IF EXISTS layoffs_staging2;

CREATE TABLE layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT,
    row_num INT
);

INSERT INTO layoffs_staging2 (
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    row_num
)
SELECT company,
       location,
       industry,
       total_laid_off,
       percentage_laid_off,
       `date`,
       stage,
       country,
       funds_raised_millions,
       ROW_NUMBER() OVER (
           PARTITION BY company,
                        location,
                        industry,
                        total_laid_off,
                        percentage_laid_off,
                        `date`,
                        stage,
                        country,
                        funds_raised_millions
           ORDER BY company
       ) AS row_num
FROM layoffs_staging;

-- Keep the first occurrence and remove later duplicates.
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- ============================================================
-- 3. STANDARDIZE DATA
-- ============================================================

-- Inspect industry values.
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

-- Turn empty strings into NULL.
UPDATE layoffs_staging2
SET industry = NULL
WHERE TRIM(industry) = '';

-- Where possible, fill missing industry values from another
-- record belonging to the same company.
UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Standardize the different Crypto labels.
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Standardize country punctuation.
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- Check the result.
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

-- Convert the date text to a real DATE value.
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL
  AND `date` <> '';

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- ============================================================
-- 4. INSPECT NULL VALUES
-- ============================================================

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
   OR percentage_laid_off IS NULL
   OR funds_raised_millions IS NULL;

-- NULLs in these fields can be legitimate unknown values,
-- so they are retained for analysis.

-- ============================================================
-- 5. REMOVE RECORDS WITH NO LAYOFF INFORMATION
-- ============================================================

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Remove the temporary duplicate-numbering column.
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- ============================================================
-- 6. FINAL QUALITY CHECK
-- ============================================================

SELECT COUNT(*) AS cleaned_rows
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
ORDER BY `date`, company;
