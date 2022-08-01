
## Case Study Questions

### 1. What is the total amount each customer spent at the restaurant?

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

_______________________________________________________________________________________________________________________________________________________


### 2. How many days has each customer visited the restaurant?

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


_______________________________________________________________________________________________________________________________________________________



### 3.  What was the first item from the menu purchased by each customer?


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


_______________________________________________________________________________________________________________________________________________________


### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT COUNT(s.product_id) AS most_purchased, 
 m.product_name, m.product_id
FROM sales s JOIN menu m ON s.product_id = m.product_id
GROUP BY s.product_id, m.product_name
ORDER BY most_purchased DESC
````

|most_purchased|product_name|product_id|
--------------|------------|----------|
|             8|ramen       |         3|
|             4|curry       |         2|
|             3|sushi       |         1|
             


#### Comment: 
We are using a **COUNT** function to count how many items of each dish were purchased by every customer.

#### Answer: 
Ramen; it was purchased 8 times.


_______________________________________________________________________________________________________________________________________________________



### 5.  Which item was the most popular for each customer?

````sql
WITH pop_item AS (
SELECT m.product_name, s.customer_id, COUNT(m.product_id) AS order_count,
DENSE_RANK() OVER(PARTITION BY s.customer_id
ORDER BY COUNT(m.product_id)DESC) AS order_rank 
FROM sales s 
JOIN menu m 
ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
)
SELECT product_name, customer_id, order_count
FROM pop_item
WHERE order_rank = 1;
````
product_name|customer_id|order_count|
------------|-----------|-----------|
ramen       |A          |          3|
sushi       |B          |          2|
ramen       |B          |          2|
curry       |B          |          2|
ramen       |C          |          3|


#### Comment: 
First we are creating a temp table to rank the total purchased items by every customer and then finding out what item was the most popular for each customer. 

#### Answer: 
Customer A and C prefer ramen, while customer B likes all 3 dishes.

_______________________________________________________________________________________________________________________________________________________

### 6. Which item was purchased first by the customer after they became a member?

````sql
WITH first_item AS (
SELECT s.customer_id, s.order_date, m.join_date, s.product_id,
DENSE_RANK () OVER (PARTITION BY s.customer_id 
ORDER BY s.order_date) AS order_date_rank
FROM sales s
JOIN members m 
ON s.customer_id = m.customer_id
WHERE s.order_date >= m.join_date)

SELECT o.customer_id, m2.product_name, o.order_date, o.product_id
FROM menu m2
JOIN first_item o 
ON o.product_id = m2.product_id
WHERE order_date_rank = 1
ORDER BY customer_id

````

customer_id|product_name|order_date|product_id|
-----------|------------|----------|----------|
A          |curry       |2021-01-07|         2|
B          |sushi       |2021-01-11|         1|

#### Comment: 
Creating a temp table to rank order dates and filtering out all the dates when the customers were not members yet. After that we are interested in the items with ```order_date_rank``` equal 1. 

#### Answer: 
Customer A's first order is curry, B's - sushi. 


_______________________________________________________________________________________________________________________________________________________


### 7. Which menu item(s) was purchased just before the customer became a member and when?
 
 ````sql
 WITH before_join AS (
 
 SELECT s.customer_id, s.order_date, m.join_date, s.product_id,
 DENSE_RANK () OVER(PARTITION BY s.customer_id
 ORDER BY s.order_date DESC) AS order_rank
 FROM sales s
 JOIN members m 
 ON s.customer_id = m.customer_id
 WHERE m.join_date>s.order_date )
 
 SELECT m2.product_name, b.order_date, b.join_date, b.order_rank, b.customer_id
 
 FROM menu m2
 JOIN before_join b
ON m2.product_id = b.product_id
WHERE order_rank = 1
ORDER BY customer_id
````

product_name|order_date|join_date |order_rank|customer_id|
------------|----------|----------|----------|-----------|
sushi       |2021-01-01|2021-01-07|         1|A          |
curry       |2021-01-01|2021-01-07|         1|A          |
sushi       |2021-01-04|2021-01-09|         1|B          |


#### Comment:
First we are going to create a temp table and rank the order dates and filter out all the dates after the customers became members. After that we going to look at the items that were purchased right before the customers became members. 

#### Answer: 
Customer A: sushi and curry, customer B: sushi


_______________________________________________________________________________________________________________________________________________________


### 8. What is the total items and amount spent for each member before they became a member?

````sql
SELECT s.customer_id, COUNT (s.product_id), SUM (m.price), e.join_date, s.order_date
FROM ((menu m JOIN sales s ON m.product_id = s.product_id) JOIN members e ON e.customer_id = s.customer_id)
WHERE s.order_date < e.join_date
GROUP BY s.customer_id
````
customer_id|COUNT (s.product_id)|SUM (m.price)|join_date |order_date|
-----------|--------------------|-------------|----------|----------|
A          |                   2|           25|2021-01-07|2021-01-01|
B          |                   3|           40|2021-01-09|2021-01-04|

#### Comment:
Using **COUNT** and **SUM** functions and filtering out order dates after customers became members. 


#### Answer: 

Customer A spent $25 and bought 2 items;
Customer B spent $40 on 3 items.


_______________________________________________________________________________________________________________________________________________________

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
 
````sql 
 WITH food_points AS (
 
 SELECT *,
 CASE WHEN product_id = 1 THEN price*20 
 ELSE price*10
 END AS points
 FROM menu)
 
 
 SELECT s.customer_id, SUM(f.points)
 FROM food_points f
 JOIN sales s
 ON f.product_id = s.product_id
 GROUP BY s.customer_id
````

customer_id|SUM(f.points)|
-----------|-------------|
A          |          860|
B          |          940|
C          |          360|

#### Comment: 
Creating a temp table and using a **CASE WHEN** function to assign points to ordered items and  sum up the points later. 


#### Answer: 
Customer A: 860, customer B: 940, customer C: 360
 
_______________________________________________________________________________________________________________________________________________________



### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, – not just sushi — how many points do customer A and B have at the end of January?
 
 ````sql
 WITH dates_cte AS (

  SELECT *, 
      DATE( join_date, '+6 days') AS join_week, 
      DATE('2021-01-01','+1 month','-1 day') AS last_date
   FROM members m)

  SELECT s.customer_id, d.last_date, s.order_date, d.join_week,
  SUM(CASE  WHEN 	s.product_id = 1 THEN m.price*20
  WHEN s.order_date BETWEEN join_date AND join_week THEN m.price*20
  ELSE m.price*10 END) AS points
  
  FROM menu m
  JOIN sales s 
  ON m.product_id = s.product_id 
  JOIN dates_cte d
  ON d.customer_id = s.customer_id
  WHERE s.order_date < d.last_date
  GROUP BY s.customer_id
````

customer_id|last_date |order_date|join_week |points|
-----------|----------|----------|----------|------|
A          |2021-01-31|2021-01-01|2021-01-13|  1370|
B          |2021-01-31|2021-01-01|2021-01-15|   820|


#### Comment: 
First we are creating a temp table ```dates_cte``` to handle the date part of the question. After that, we are using **SUM** and **CASE WHEN** to assign points to the ordered items and then sum them up. 

#### Answer: 
A: 1370, B: 820


_______________________________________________________________________________________________________________________________________________________




### Bonus Question:

### 11. Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)


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




