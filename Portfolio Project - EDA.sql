-- Layoffs Exploratory Data Analysis
-- MySQL
-- Expected cleaned table: world_layoffs.layoffs_staging2
--
-- Goal: explore the cleaned dataset and identify useful patterns,
-- trends, concentrations and unusual observations.

USE world_layoffs;

-- ============================================================
-- 1. QUICK OVERVIEW
-- ============================================================

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off) AS largest_single_layoff
FROM layoffs_staging2;

SELECT MAX(percentage_laid_off) AS largest_percentage,
       MIN(percentage_laid_off) AS smallest_percentage
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;

-- Companies where the reported percentage is 100%.
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- ============================================================
-- 2. COMPANIES WITH THE LARGEST LAYOFFS
-- ============================================================

-- Largest single reported event.
SELECT company,
       total_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC
LIMIT 5;

-- Largest cumulative layoffs by company.
SELECT company,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 10;

-- ============================================================
-- 3. LOCATION / COUNTRY
-- ============================================================

SELECT location,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY location
ORDER BY total_laid_off DESC
LIMIT 10;

SELECT country,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC;

-- ============================================================
-- 4. TIME TRENDS
-- ============================================================

SELECT YEAR(`date`) AS layoff_year,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY layoff_year;

-- Monthly totals.
SELECT DATE_FORMAT(`date`, '%Y-%m') AS month,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY DATE_FORMAT(`date`, '%Y-%m')
ORDER BY month;

-- ============================================================
-- 5. INDUSTRY AND COMPANY STAGE
-- ============================================================

SELECT industry,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_laid_off DESC;

SELECT stage,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;

-- ============================================================
-- 6. TOP COMPANIES BY YEAR
-- ============================================================

WITH company_year AS (
    SELECT company,
           YEAR(`date`) AS layoff_year,
           SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY company, YEAR(`date`)
),
ranked_companies AS (
    SELECT company,
           layoff_year,
           total_laid_off,
           DENSE_RANK() OVER (
               PARTITION BY layoff_year
               ORDER BY total_laid_off DESC
           ) AS ranking
    FROM company_year
)
SELECT company,
       layoff_year,
       total_laid_off,
       ranking
FROM ranked_companies
WHERE ranking <= 3
ORDER BY layoff_year, total_laid_off DESC;

-- ============================================================
-- 7. ROLLING TOTAL OF MONTHLY LAYOFFS
-- ============================================================

WITH monthly_layoffs AS (
    SELECT DATE_FORMAT(`date`, '%Y-%m') AS month,
           SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    WHERE `date` IS NOT NULL
    GROUP BY DATE_FORMAT(`date`, '%Y-%m')
)
SELECT month,
       total_laid_off,
       SUM(total_laid_off) OVER (
           ORDER BY month
       ) AS rolling_total_layoffs
FROM monthly_layoffs
ORDER BY month;
