# 📊 SQL Project: Data Cleaning for Global Layoffs Dataset
This project demonstrates a robust, multi-stage data cleaning workflow using SQL to transform raw, messy recruitment and layoff data into a structured format suitable for analysis. The process utilizes a "Staging" methodology to protect raw data integrity while performing complex transformations.

## 📂 Dataset Source
- Source: https://www.kaggle.com/datasets/swaptr/layoffs-2022
- Period: Includes global layoff data from the COVID-19 pandemic through 2024.
- Format: Raw CSV file containing 9 initial columns.

## 🛠️ The Cleaning Pipeline
Data Staging & Schema Prep
- Initial Clone: Created layoffs_staging to preserve the original raw dataset.
- Unique Identification: Injected an id INT AUTO_INCREMENT PRIMARY KEY to ensure every row could be uniquely identified for precise updates.

🛠️ De-Duplication
- Identification: Used a Common Table Expression (CTE) and the ROW_NUMBER() window function to find rows with identical company, location, date, and industry data.
- Removal: Transferred data to layoffs_staging2 and executed a DELETE command where the row count was greater than 1, physically removing all duplicates.

✍️ String Standardization
- Trim & Clean: Applied TRIM() to the company column to fix spacing issues.
- Location Cleanup: Used TRIM(TRAILING ', Non-U.S.' FROM location) to standardize geographic entries.
- Fuzzy Matching: Leveraged the SOUNDEX() function to audit and group similar-sounding locations to ensure naming consistency.

🧩 Data Type Refinement & Null Handling
- Type Conversion: Modified total_laid_off to INT and percentage_laid_off to DECIMAL for mathematical accuracy.
- Date Formatting: Converted text-based dates into true DATE objects using STR_TO_DATE for both the date and date_added columns.
- Nullification: Converted empty strings ('') into formal NULL values to improve the accuracy of aggregate functions.

🚀 Feature Engineering
- Workforce Estimation: Created estimated_total_employees by back-calculating using the ratio: total_laid_off / percentage_laid_off.
- Categorization: Added a company_size_bucket column using a CASE statement to segment companies into Small, Medium, or Large.
- Event Tracking: Added layoff_event_count to track how many times a specific company branch appeared in the dataset using partitioned counts.



