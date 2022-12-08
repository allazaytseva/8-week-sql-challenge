### A. Data Cleansing Steps

#### Assignement 

In a single query, perform the following operations and generate a new table in the `data_mart` schema named `clean_weekly_sales`:
- Convert the `week_date` to a `DATE` format
- Add a `week_number` as the second column for each `week_date` value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
- Add a `month_number` with the calendar month for each `week_date` value as the 3rd column
- Add a `calendar_year` column as the 4th column containing either 2018, 2019 or 2020 values
- Add a new column called `age_band` after the original segment column using the following mapping on the number inside the segment value
  
<img width="166" alt="image" src="https://user-images.githubusercontent.com/81607668/131438667-3b7f3da5-cabc-436d-a352-2022841fc6a2.png">
  
- Add a new `demographic` column using the following mapping for the first letter in the `segment` values:  

| segment | demographic | 
| ------- | ----------- |
| C | Couples |
| F | Families |

- Ensure all `null` string values with an "unknown" string value in the original `segment` column as well as the new `age_band` and `demographic` columns
- Generate a new `avg_transaction` column as the sales value divided by transactions rounded to 2 decimal places for each record

```sql

DROP TABLE IF EXISTS clean_weekly_sales;

CREATE TEMP TABLE clean_weekly_sales AS (
  SELECT
    TO_DATE (week_date, 'DD/MM/YY') AS week_date,
    DATE_PART ('week', TO_DATE (week_date, 'DD/MM/YY')) AS week_number,
    DATE_PART ('month', TO_DATE (week_date, 'DD/MM/YY')) AS month_number,
    DATE_PART ('year', TO_DATE (week_date, 'DD/MM/YY')) AS calendar_year,
    region,
    platform,
    segment,
    CASE
      WHEN RIGHT (segment, 1) = '1' THEN 'Young Adults'
      WHEN RIGHT (segment, 1) = '2' THEN 'Middle Aged'
      WHEN RIGHT (segment, 1) IN ('3', '4') THEN 'Retirees'
      ELSE 'Unknown'
    END AS age_band,
    CASE
      WHEN LEFT (segment, 1) = 'C' THEN 'Couples'
      WHEN LEFT (segment, 1) = 'F' THEN 'Families'
      ELSE 'Unknown'
    END AS demographic,
    transactions,
    sales,
    customer_type,
    ROUND((sales :: NUMERIC / transactions), 2) AS avg_transactions
  FROM
    data_mart.weekly_sales
);


SELECT
  *
FROM
  clean_weekly_sales
```

Here's the result: 

![Screen Shot 2022-12-08 at 12 34 34 PM](https://user-images.githubusercontent.com/95102899/206564661-ebf2677b-f1a6-4a1e-96a3-115819322ceb.png)
