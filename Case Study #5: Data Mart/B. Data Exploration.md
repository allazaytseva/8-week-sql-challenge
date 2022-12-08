### B. Data Exploration 


**1. What day of the week is used for each week_date value?**

```sql

SELECT DATE_PART ('dow', week_date), TO_CHAR (week_date, 'Day') AS dow
FROM clean_weekly_sales
```

![Screen Shot 2022-12-08 at 12 52 37 PM](https://user-images.githubusercontent.com/95102899/206565222-bbe47b67-9091-4817-a01c-54f6c6160f9d.png)

_______________________________________________________________________________________________________________________________________________________



**2. What range of week numbers are missing from the dataset?**

```sql
WITH gen_series_cte AS (
  SELECT
    GENERATE_SERIES (1, 52) AS week_number
  FROM
    clean_weekly_sales
)
SELECT
  DISTINCT g.week_number
FROM
  gen_series_cte g
  LEFT OUTER JOIN clean_weekly_sales c ON g.week_number = c.week_number
WHERE
  c.week_number IS NULL
ORDER BY
  1 --- we have 28 rows returned - meaning that we are missing 28 weeks
```

![Screen Shot 2022-12-08 at 12 58 05 PM](https://user-images.githubusercontent.com/95102899/206566162-6de50ce0-2ff7-4b94-9b88-5f3ec44e0f8b.png)

_______________________________________________________________________________________________________________________________________________________


**3. How many total transactions were there for each year in the dataset?**

```sql
SELECT 
calendar_year, 
SUM (transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year
```

![Screen Shot 2022-12-08 at 1 09 49 PM](https://user-images.githubusercontent.com/95102899/206568068-82735414-b7b7-485e-86e1-1f8c44b14ed6.png)

_______________________________________________________________________________________________________________________________________________________


**4. What is the total sales for each region for each month?**

```sql
SELECT region, month_number, 
SUM (sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number
```

![Screen Shot 2022-12-08 at 1 13 02 PM](https://user-images.githubusercontent.com/95102899/206568594-3d71aa02-cfa1-4a19-89e8-afbd1242cc19.png)


_______________________________________________________________________________________________________________________________________________________


**5. What is the total count of transactions for each platform?**

```sql
SELECT 
platform, 
SUM (transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform
ORDER BY platform
```

![Screen Shot 2022-12-08 at 1 17 24 PM](https://user-images.githubusercontent.com/95102899/206569459-423bd3d0-0aeb-40ad-84a5-0c96dddda7e7.png)



_______________________________________________________________________________________________________________________________________________________


**6. What is the percentage of sales for Retail vs Shopify for each month?**

```sql
WITH cte AS (
SELECT 
calendar_year, month_number,platform,
SUM (sales) AS monthly_sales 
FROM clean_weekly_sales
GROUP BY calendar_year,month_number, platform
ORDER BY calendar_year,month_number, platform)

SELECT 
  calendar_year, 
  month_number, 
  ROUND(100 * MAX 
    (CASE WHEN platform = 'Retail' THEN monthly_sales ELSE NULL END) / 
      SUM(monthly_sales),2) AS retail_percentage,
  ROUND(100 * MAX 
    (CASE WHEN platform = 'Shopify' THEN monthly_sales ELSE NULL END) / 
      SUM(monthly_sales),2) AS shopify_percentage
  FROM cte
  GROUP BY calendar_year, month_number
  ORDER BY calendar_year, month_number;
 ```
 
 ![Screen Shot 2022-12-08 at 1 19 23 PM](https://user-images.githubusercontent.com/95102899/206569811-c105c171-123d-4adf-9202-62ee45a71485.png)



_______________________________________________________________________________________________________________________________________________________


**7. What is the percentage of sales by demographic for each year in the dataset?**

```sql
WITH cte AS (
SELECT 
calendar_year, demographic,
SUM (sales) AS yearly_sales 
FROM clean_weekly_sales
GROUP BY calendar_year, demographic
)
  
  SELECT 
  calendar_year, 
 
  ROUND(100 * MAX 
    (CASE WHEN demographic = 'Couples' THEN yearly_sales ELSE NULL END) / 
      SUM(yearly_sales),2) AS couple_percentage,
  ROUND(100 * MAX 
    (CASE WHEN demographic = 'Families' THEN yearly_sales ELSE NULL END) / 
      SUM(yearly_sales),2) AS families_percentage,
  ROUND (100* MAX
    (CASE WHEN demographic = 'Unknown' THEN yearly_sales ELSE NULL END)/
      SUM(yearly_sales),2) AS unknown_demographic_percentage
  FROM cte
  GROUP BY calendar_year 
  ORDER BY calendar_year;
```

![Screen Shot 2022-12-08 at 1 20 39 PM](https://user-images.githubusercontent.com/95102899/206569982-0875d5a9-3c40-47ba-95d8-8e94b24f23f8.png)

_______________________________________________________________________________________________________________________________________________________

**8. Which age_band and demographic values contribute the most to Retail sales?**

```sql
SELECT age_band, demographic, 
SUM (sales),
ROUND(100 * SUM(sales)::NUMERIC / SUM(SUM(sales)) OVER (),2) AS contribution_percentage
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY 3 DESC
```
![Screen Shot 2022-12-08 at 1 22 20 PM](https://user-images.githubusercontent.com/95102899/206570168-f0224fbc-d247-405b-9e1d-133f8958de46.png)

  

_______________________________________________________________________________________________________________________________________________________


**9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?**

```sql
SELECT calendar_year, platform, ROUND(AVG(avg_transactions), 0) AS avg_transactions_gen, 
SUM(sales) / sum(transactions) AS avg_transaction_group
FROM clean_weekly_sales
GROUP BY platform, calendar_year
ORDER BY calendar_year
```
![Screen Shot 2022-12-08 at 1 23 04 PM](https://user-images.githubusercontent.com/95102899/206570297-9864eb45-765f-4371-b2d4-5952d6adcf27.png)


