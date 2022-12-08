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


_______________________________________________________________________________________________________________________________________________________


**4. What is the total sales for each region for each month?**


_______________________________________________________________________________________________________________________________________________________


**5. What is the total count of transactions for each platform?**


_______________________________________________________________________________________________________________________________________________________


**6. What is the percentage of sales for Retail vs Shopify for each month?**


_______________________________________________________________________________________________________________________________________________________


**7. What is the percentage of sales by demographic for each year in the dataset?**


_______________________________________________________________________________________________________________________________________________________

**8. Which age_band and demographic values contribute the most to Retail sales?**

_______________________________________________________________________________________________________________________________________________________


**9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?**
