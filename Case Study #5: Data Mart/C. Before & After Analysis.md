### C. Before & After Analysis 

#### Assignement 
This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the `week_date` value of `2020-06-15` as the baseline week where the Data Mart sustainable packaging changes came into effect. We would include all `week_date` values for `2020-06-15` as the start of the period after the change and the previous week_date values would be before.

Using this analysis approach - answer the following questions:
1. What is the total sales for the 4 weeks before and after `2020-06-15`? What is the growth or reduction rate in actual values and percentage of sales?
2. What about the entire 12 weeks before and after?
3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?


**1. What is the total sales for the 4 weeks before and after `2020-06-15`? What is the growth or reduction rate in actual values and percentage of sales?**

First we need to figure out what week number is June 15 2020:

```sql
SELECT DISTINCT week_number
FROM clean_weekly_sales
WHERE week_date = '2020-06-15'
```

| week_number | 
| ------- | 
| 25 | 


```sql
WITH cte1 AS (
SELECT week_number, week_date, 
SUM(sales::NUMERIC) AS total_sales
FROM clean_weekly_sales
WHERE (calendar_year = 2020) AND
(week_number BETWEEN 21 AND 28)
GROUP BY week_date, week_number),

cte2 AS (
SELECT 
SUM (CASE WHEN week_number BETWEEN 21 AND 24 THEN total_sales::NUMERIC END) AS before_sales,
SUM (CASE WHEN week_number BETWEEN 25 AND 28 THEN total_sales::NUMERIC END) AS after_sales
FROM cte1 
)

SELECT *,
after_sales - before_sales AS sales_diff,
ROUND((100 * (after_sales - before_sales)/before_sales),2) percentage
FROM cte2
```

![Screen Shot 2022-12-08 at 1 32 54 PM](https://user-images.githubusercontent.com/95102899/206571997-62e9f6ef-fbe2-43a5-8c22-11c57f102e54.png)


As a result, we got sales result before the new packaging was introduced, sales result after the packaging was introduced, the difference between them in dollars and percentage. As we see, sales were better before the packaging was changed. 

**2. What about the entire 12 weeks before and after?**

```sql
WITH cte1 AS (
SELECT week_number, week_date, 
SUM(sales::NUMERIC) AS total_sales
FROM clean_weekly_sales
WHERE (calendar_year = 2020) AND
(week_number BETWEEN 21 AND 28)
GROUP BY week_date, week_number),

cte2 AS (
SELECT 
SUM (CASE WHEN week_number BETWEEN 21 AND 24 THEN total_sales::NUMERIC END) AS before_sales,
SUM (CASE WHEN week_number BETWEEN 25 AND 28 THEN total_sales::NUMERIC END) AS after_sales
FROM cte1 
)

SELECT *,
after_sales - before_sales AS sales_diff,
ROUND((100 * (after_sales - before_sales)/before_sales),2) percentage
FROM cte2
```
![Screen Shot 2022-12-08 at 1 35 04 PM](https://user-images.githubusercontent.com/95102899/206572385-7b7e5329-ec41-4ee0-be0e-96983a3ed3d5.png)

As we see in the table, sales are still worse 12 weeks after the packaging was changed.

**3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?**

Here, we'll introduce ``calendar_year`` in the GROUP BY function.

```sql
---4 weeks before and after for 2018, 2019, 2020
WITH cte1 AS (
SELECT week_number, week_date, calendar_year,
SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE  
week_number BETWEEN 21 AND 28
GROUP BY calendar_year, week_date, week_number),

cte2 AS (
SELECT calendar_year,
SUM (CASE WHEN week_number BETWEEN 21 AND 24 THEN total_sales END) AS before_sales,
SUM (CASE WHEN week_number BETWEEN 25 AND 28 THEN total_sales END) AS after_sales
FROM cte1 
GROUP BY calendar_year
)

SELECT *,
after_sales - before_sales AS sales_diff,
ROUND((100 * (after_sales - before_sales)/before_sales),2) percentage
FROM cte2
```

![Screen Shot 2022-12-08 at 1 37 27 PM](https://user-images.githubusercontent.com/95102899/206572881-f6e1b64d-b49f-4679-b0c1-00e84d146284.png)

---12 weeks before and after for 2018, 2019, 2020

```sql 
WITH cte1 AS (
SELECT week_number, week_date, calendar_year,
SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE  
week_number BETWEEN 13 AND 36
GROUP BY calendar_year, week_date, week_number),

cte2 AS (
SELECT calendar_year,
SUM (CASE WHEN week_number BETWEEN 13 AND 24 THEN total_sales END) AS before_sales,
SUM (CASE WHEN week_number BETWEEN 25 AND 36 THEN total_sales END) AS after_sales
FROM cte1 
GROUP BY calendar_year
)

SELECT *,
after_sales - before_sales AS sales_diff,
ROUND((100 * (after_sales - before_sales)/before_sales),2) percentage
FROM cte2
```

![Screen Shot 2022-12-08 at 1 38 56 PM](https://user-images.githubusercontent.com/95102899/206572967-87d89c2a-55d0-43ee-9393-ea58732d06e9.png)


