SELECT *
FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;



WITH duplicates_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, country
) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicates_cte
WHERE row_num > 1;



ALTER TABLE layoffs_staging
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;



ALTER TABLE layoffs_staging
ADD COLUMN row_num INT;

UPDATE layoffs_staging AS t1
JOIN(
	SELECT id,
	ROW_NUMBER() OVER(
	PARTITION BY company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, country
	) AS row_num
	FROM layoffs_staging
) AS t2
ON t1.id = t2.id
SET t1.row_num = t2.row_num;


CREATE TABLE layoffs_staging2
LIKE layoffs_staging;

INSERT layoffs_staging2
SELECT *
FROM layoffs_staging;





SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;







SELECT COUNT(DISTINCT location)
FROM layoffs_staging2;

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

SELECT location, SOUNDEX(location)
FROM layoffs_staging2
GROUP BY location
ORDER BY SOUNDEX(location);

SELECT location
FROM layoffs_staging2
WHERE location LIKE '%, Non-U.S.%';

SELECT DISTINCT location, TRIM(TRAILING ', Non-U.S.' FROM location)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET location = TRIM(TRAILING ', Non-U.S.' FROM location)
WHERE location LIKE '%, Non-U.S.%';









SELECT *
FROM layoffs_staging2
WHERE location = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE '%Product%';

UPDATE layoffs_staging2
SET location = 'Unknown'
WHERE location = '';



SELECT COUNT(DISTINCT company)
FROM layoffs_staging2;

SELECT DISTINCT company
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT TRIM(company)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT company
FROM layoffs_staging2
WHERE company IS NULL;


SELECT company, location, COUNT(company)
FROM layoffs_staging2
WHERE company REGEXP '[0-9]'
GROUP BY company, location
ORDER BY 3;







SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT company, location, industry
FROM layoffs_staging2
WHERE industry = '';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2
SET industry = 'Other'
WHERE industry IS NULL;








UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging AS t2
	ON t1.id = t2.id
SET t1.total_laid_off = t2.total_laid_off, t1.percentage_laid_off = t2.percentage_laid_off;








SELECT *
FROM layoffs_staging2
WHERE total_laid_off = ''
AND percentage_laid_off = '';

UPDATE layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = '';

UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = '';

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL 
AND percentage_laid_off IS NOT NULL;

SELECT total_laid_off
FROM layoffs_staging2
WHERE total_laid_off LIKE '%.__';

ALTER TABLE layoffs_staging2
MODIFY COLUMN total_laid_off INT;





SELECT percentage_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off LIKE '%.___';

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off > 1;

ALTER TABLE layoffs_staging2
MODIFY COLUMN percentage_laid_off DECIMAL(4,3);

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 0;

SELECT *
FROM layoffs_staging2
WHERE company = 'TaskUs';


UPDATE layoffs_staging2
SET funds_raised = NULL
WHERE funds_raised = '';



ALTER TABLE layoffs_staging2
ADD COLUMN estimated_total_employees INT;

UPDATE layoffs_staging2
SET estimated_total_employees = ROUND(total_laid_off/percentage_laid_off)
WHERE total_laid_off IS NOT NULL
AND percentage_laid_off IS NOT NULL
AND percentage_laid_off != 0;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL 
AND percentage_laid_off IS NOT NULL
AND estimated_total_employees IS NULL;

SELECT *
FROM layoffs_staging2
WHERE estimated_total_employees IS NOT NULL;






SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


UPDATE layoffs_staging2
SET `date_added` = STR_TO_DATE(`date_added`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date_added` DATE;







SELECT company, location, estimated_total_employees
FROM layoffs_staging2
WHERE estimated_total_employees IS NOT NULL;

ALTER TABLE layoffs_staging2
ADD COLUMN company_size_bucket TEXT;

UPDATE layoffs_staging2
SET company_size_bucket = CASE
	WHEN estimated_total_employees < 1000 THEN 'Small'
    WHEN estimated_total_employees BETWEEN 1000 AND 10000 THEN 'Medium'
    WHEN estimated_total_employees > 10000 THEN 'Large'
    ELSE 'Unknown'
END;

SELECT company, 
location, 
industry, 
estimated_total_employees, 
comapany_size_bucket,
total_laid_off,
percentage_laid_off
FROM layoffs_staging2
WHERE estimated_total_employees IS NOT NULL;



ALTER TABLE layoffs_staging2
ADD COLUMN layoff_event_count INT;



SELECT company, location, COUNT(*) OVER(PARTITION BY company, location) AS layoff_count
FROM layoffs_staging2
ORDER BY company;


WITH frequency AS(
	SELECT company, location, COUNT(*) OVER(PARTITION BY company, location) AS layoff_event_count
	FROM layoffs_staging2
)
UPDATE layoffs_staging2
JOIN frequency
	ON layoffs_staging2.company = frequency.company
    AND layoffs_staging2.location = frequency.location
SET layoffs_staging2.layoff_event_count = frequency.layoff_event_count;



ALTER TABLE layoffs_staging2
ADD COLUMN layoff_reported INT;

UPDATE layoffs_staging2
SET layoff_reported = CASE
	WHEN estimated_total_employees IS NOT NULL THEN 1
    ELSE 0
END;



SELECT *
FROM layoffs_staging2;



CREATE TABLE layoffs_staging3 AS
SELECT company, location, country, industry, stage,
total_laid_off, percentage_laid_off, `date`, 
estimated_total_employees, company_size_bucket,
funds_raised, `date_added`, layoff_event_count, layoff_reported
FROM layoffs_staging2;


SELECT *
FROM layoffs_staging3;




