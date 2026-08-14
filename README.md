# SQL Data Cleaning & Exploratory Data Analysis

## Project Overview

This project focuses on **data cleaning and exploratory data analysis of a layoffs dataset using MySQL**.

The project is divided into two SQL scripts:

* **Portfolio Project - Data Cleaning.sql** — cleans and prepares the raw layoffs dataset.
* **Portfolio Project - EDA.sql** — analyzes the cleaned dataset to identify trends, patterns, and insights.

## Data Cleaning

The data cleaning process includes:

* Creating a staging copy of the original dataset
* Identifying and removing duplicate records
* Standardizing inconsistent values
* Handling blank and NULL values
* Standardizing industry and country information
* Converting date values into a proper DATE format
* Removing records with no usable layoff information
* Performing final data quality checks

## Exploratory Data Analysis

The EDA explores several aspects of layoffs, including:

* Largest individual layoffs
* Companies with the highest total layoffs
* Layoffs by country and location
* Layoffs by year and month
* Industries with the highest number of layoffs
* Layoffs by company stage
* Top companies by year
* Monthly rolling totals of layoffs
* Companies with the highest percentage of layoffs

The analysis uses SQL aggregation, grouping, filtering, CTEs, and window functions such as `DENSE_RANK()` and `SUM() OVER()`.

## Tools Used

* **MySQL**
* **SQL**
* **MySQL Workbench**

## Project Workflow

```text
Raw Layoffs Data
       ↓
Staging Table
       ↓
Duplicate Removal
       ↓
Data Standardization
       ↓
NULL & Missing Data Handling
       ↓
Date Conversion
       ↓
Final Data Quality Checks
       ↓
Exploratory Data Analysis
       ↓
Trends & Insights
```

## Repository Structure

| File                                    | Description                                                |
| --------------------------------------- | ---------------------------------------------------------- |
| `Portfolio Project - Data Cleaning.sql` | SQL script used to clean and prepare the layoffs dataset   |
| `Portfolio Project - EDA.sql`           | SQL script used to explore and analyze the cleaned dataset |

## SQL Techniques Used

* `CREATE TABLE`
* `INSERT`
* `UPDATE`
* `DELETE`
* `ALTER TABLE`
* `GROUP BY`
* `ORDER BY`
* Aggregate functions
* Common Table Expressions (CTEs)
* Window functions
* `ROW_NUMBER()`
* `DENSE_RANK()`
* Date functions
* Data standardization
* Data quality checks

## Dataset

The dataset contains information related to company layoffs, including:

* Company
* Location
* Industry
* Total Laid Off
* Percentage Laid Off
* Date
* Company Stage
* Country
* Funds Raised

## Author

**Vennila Reddy**
