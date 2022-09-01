
### 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

````sql
SELECT 
SUM(
  CASE WHEN c.pizza_id = 1 THEN 12
       WHEN c.pizza_id = 2 THEN 10
       END) AS revenue
FROM customer_orders1 c
INNER JOIN runner_orders2 r 
ON c.order_id = r.order_id
WHERE r.distance IS NOT NULL;
````

|revenue|
|-----|
|138|

#### Answer: 138

### 2. What if there was an additional $1 charge for any pizza extras? + Add cheese is $1 extra

````sql
WITH cte_extras AS(
SELECT 
c.order_id, 
UNNEST(STRING_TO_ARRAY(c.extras, ','))::INTEGER AS pizza_extras
FROM customer_orders1 c
INNER JOIN runner_orders2 r 
ON c.order_id = r.order_id
WHERE r.distance IS NOT NULL) 

SELECT 
SUM(revenue)
FROM (
  SELECT
  SUM(CASE WHEN pizza_extras IS NULL THEN 0
    ELSE 1 END) AS revenue
  FROM cte_extras
  
  UNION ALL
  
  SELECT 
  SUM(
  CASE WHEN c.pizza_id = 1 THEN 12
       WHEN c.pizza_id = 2 THEN 10
       END) AS revenue
  FROM customer_orders1 c
  INNER JOIN runner_orders2 r 
  ON c.order_id = r.order_id
  WHERE r.distance IS NOT NULL) as final_revenue
  ````
  |sum|
|-----|
|142|
  
### 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

````sql
DROP TABLE IF EXISTS ratings;

CREATE TABLE ratings (
"order_id" INTEGER,
"rating" INTEGER, 
"review" VARCHAR (200)
);
INSERT INTO ratings 
("order_id", "rating", "review")
VALUES 
('1', '3', 'none'),
('2', '5', 'fast service') ,
('3', '5', 'none'),
('4', '5', 'none'),
('5', '3', 'cold pizza'),
('6','5', '-'),
('7', '2', 'food not as expected'),
('8', '5', 'great service'),
('9', '5', 'none'), 
('10', '4', 'delivery guy was 30min late');
````
````sql
SELECT *
FROM ratings
````

|order_id|rating|review|
--------------|------------|----------|
|             1|3       |        none |
|             2|5       |         fast service|
|             3|5       |         none|
|             4|5       |         none|
|             5|3       |         cold pizza|
|             6|5       |         -|
|             7|2      |         food not as expected|
|             8|5       |         great service|
|             9|5      |         none|
|             10|4       |         delivery guy was 30min late|

