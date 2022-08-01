
### Case Study Questions

1. What is the total amount each customer spent at the restaurant?

````sql
SELECT s.customer_id, m.price,  SUM (m.price)
FROM menu m JOIN sales s 
ON m.product_id = s.product_id 
GROUP BY customer_id
ORDER BY s.customer_id 
````

|customer_id |price| SUM (m.price)|
|----------- | ---- | ----------- |
|A           |  10|         76|
|B           |  10|         74|
|C           |  12|         36|

#### Answer: 
Customer A: $76

Customer B: $74

Customer C: $36



2. How many days has each customer visited the restaurant?

````sql
SELECT customer_id,  COUNT (DISTINCT order_date)
FROM sales 
GROUP BY customer_id
````


customer_id|COUNT (DISTINCT order_date)|
-----------|---------------------------|
A          |                          4|
B          |                          6|
C          |                          2|

#### Comment: 
It is important here to use **COUNT(DISTINCT ...)** to find the number of days each customer visited the restaurant. If we don't use **DISTINCT** we might end up with a larger number as customers could visit the restaurant more than once. 

#### Answer: 
Customer A: 4

Customer B: 6

Customer C: 2


3.  What was the first item from the menu purchased by each customer?


````sql
WITH ordered_sales AS (
SELECT s.customer_id, s.order_date, m.product_name,
DENSE_RANK () OVER (PARTITION BY s.customer_id 
ORDER BY s.order_date) AS order_rank
FROM sales s
JOIN menu m 
ON s.product_id = m.product_id)

SELECT  customer_id, product_name
FROM ordered_sales
WHERE order_rank = 1
GROUP BY customer_id, product_name;
````

customer_id|product_name|
-----------|------------|
A          |curry       |
A          |sushi       |
B          |curry       |
C          |ramen       |

#### Comment: 

First we've created a common table expression (CTE) that acts as a temp table. It will help us rank order dates of every customer. After that we will filter out everything except for when ```order_rank``` is 1. 

#### Answer:

Customer A: curry and sushi

Customer B: curry

Customer C: ramen










### Bonus Questions:

11. Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)


````sql
SELECT s.customer_id, s.order_date, m.product_name, m.price, m2.join_date,
  CASE WHEN s.order_date >= m2.join_date THEN 'Y'
  ELSE 'N' END AS member_notmember
  FROM sales s 
  LEFT JOIN menu m
  ON  s.product_id = m.product_id 
  LEFT JOIN members m2
  ON m2.customer_id = s.customer_id 
````

| customer_id | order_date | product_name | price| join_date | member_notmember |
| ----------- | ---------- | ------------ | ---- | --------- | ---------------- |
|A            | 2021-01-01 | sushi       |   10 | 2021-01-07 | N               |
|A          | 2021-01-01 | curry       |   15|2021-01-07|N               |
|A          | 2021-01-07 | curry       |   15|2021-01-07|Y               |
|A          | 2021-01-10 | ramen       |   12|2021-01-07|Y               |
|A          | 2021-01-11 | ramen       |   12|2021-01-07|Y               |
|A          | 2021-01-11 | ramen       |   12|2021-01-07|Y               |
|B          | 2021-01-01 | curry       |   15|2021-01-09|N               |
|B          | 2021-01-02 | curry       |   15|2021-01-09|N               |
|B          | 2021-01-04 | sushi       |   10|2021-01-09|N               |
|B          | 2021-01-11 | sushi       |   10|2021-01-09|Y               |
|B          | 2021-01-16 | ramen       |   12|2021-01-09|Y               |
|B          | 2021-02-01 | ramen       |   12|2021-01-09|Y               |
|C          | 2021-01-01 | ramen       |   12| NULL     |N               |
|C          | 2021-01-01 | ramen       |   12| NULL     |N               |
|C          | 2021-01-07 | ramen       |   12| NULL     |N               |
