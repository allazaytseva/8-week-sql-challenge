--CASE STUDY #1: DANNY'S DINER--

--Author: Alla Zaytseva
--Date: August 1 2022
--Tool used: SQLite

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT *
FROM members
;

SELECT *
FROM menu;

SELECT *
FROM sales;

--- had to drop the table as I noticed that I inserted values twice 
DROP TABLE sales; 


------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. What is the total amount each customer spent at the restaurant?

SELECT m.price, m.product_id, s.product_id, s.customer_id, SUM (m.price)
FROM menu m JOIN sales s 
ON m.product_id = s.product_id 
GROUP BY customer_id

---answer: 
----Customer A: $76
----Customer B: $74
----Customer C: $36

--2. How many days has each customer visited the restaurant?

SELECT customer_id,  COUNT (DISTINCT order_date)
FROM sales 
GROUP BY customer_id

---Answer: 
----Customer A: 4
----Customer B: 6
----Customer C: 2

---3. What was the first item from the menu purchased by each customer?

WITH ordered_sales AS (

SELECT s.customer_id, s.order_date, m.product_name,
DENSE_RANK () OVER (PARTITION BY s.customer_id 
ORDER BY s.order_date) AS order_rank
FROM sales s
JOIN menu m 
ON s.product_id = m.product_id)

SELECT product_name, customer_id
FROM ordered_sales
WHERE order_rank = 1
GROUP BY customer_id, product_name;

---Answer: Customer A: curry and sushi, customer B: curry, customer C: ramen


--4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT COUNT(s.product_id) AS most_purchased , m.product_name, m.product_id
FROM sales s JOIN menu m ON s.product_id = m.product_id
GROUP BY s.product_id, m.product_name
ORDER BY most_purchased DESC

--Answer: ramen; it was purchased 8 times.


---5.  Which item was the most popular for each customer?

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

---Answer: Customer A and C prefer ramen, while customer B likes all 3 dishes.

---6. Which item was purchased first by the customer after they became a member?

WITH first_item AS (

SELECT s.customer_id, s.order_date, m.join_date, s.product_id,
DENSE_RANK () OVER (PARTITION BY s.customer_id 
ORDER BY s.order_date) AS order_date_rank
FROM sales s
JOIN members m 
ON s.customer_id = m.customer_id
WHERE s.order_date >= m.join_date)

SELECT m2.product_name, o.order_date, o.product_id, o.customer_id
FROM menu m2
JOIN first_item o 
ON o.product_id = m2.product_id
WHERE order_date_rank = 1

  ---Answer: Customer A's first order: curry, B's - sushi
  
  
 --- 7.Which menu item(s) was purchased just before the customer became a member and when?
 
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

---Answer: customer A: sushi and curry, customer B: sushi  


---8. What is the total items and amount spent for each member before they became a member?

SELECT COUNT (s.product_id), SUM (m.price), e.join_date, s.order_date, s.customer_id
FROM ((menu m JOIN sales s ON m.product_id = s.product_id) JOIN members e ON e.customer_id = s.customer_id)
WHERE s.order_date < e.join_date
GROUP BY s.customer_id

---Answer: Customer A spent $25 and bought 2 items
--- Customer B spent $40 on 3 items



---9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
 
 
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
 
 ---Answer: Customer A: 860, customer B: 940, customer C: 360
 
 
 ---10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
 --not just sushi — how many points do customer A and B have at the end of January?
 
 
 WITH dates_cte AS (

   SELECT *, 
   DATE( join_date, '+6 days') AS join_week, 
   DATE('2021-01-01','+1 month','-1 day') AS last_date
   FROM members m)
   
  SELECT d.last_date, s.order_date, d.join_week, s.customer_id,
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


---Answer: A: 1370, B: 820



---Bonus questions: 
---11. Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)
  
  SELECT s.customer_id, s.order_date, m.product_name, m.price, m2.join_date,
  CASE WHEN s.order_date >= m2.join_date THEN 'Y'
  ELSE 'N' END AS member_notmember
  FROM sales s 
  LEFT JOIN menu m
  ON  s.product_id = m.product_id 
  LEFT JOIN members m2
  ON m2.customer_id = s.customer_id 
