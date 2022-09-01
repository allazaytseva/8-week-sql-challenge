
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

### 2. What if there was an additional $1 charge for any pizza extras? The conditions from the previous question are still the same: If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

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
    SUM (
    CASE WHEN pizza_extras IS NULL THEN 0
         ELSE 1 END) AS revenue
  FROM cte_extras
  
  UNION ALL
  
  SELECT 
    SUM (
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


### 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries? + customer_id + order_id + runner_id + rating + order_time + pickup_time + Time between order and pickup + Delivery duration + Average speed + Total number of pizzas

````sql
SELECT 
  c.customer_id,
  c.order_id,
  ro.runner_id,
  r.rating, 
  c.order_time, 
  ro.pickup_time::TIMESTAMP AS pickup_time, 
  DATE_PART('minute', AGE(ro.pickup_time::TIMESTAMP, c.order_time))::INTEGER AS pickup_minutes, 
  ROUND(AVG(ro.distance::NUMERIC/ro.duration::NUMERIC *60), 2) AS avg_speed, 
  COUNT (c.order_id) AS number_of_pizzas
  
FROM customer_orders1 c 
  INNER JOIN runner_orders2 ro 
    ON c.order_id = ro.order_id
  LEFT JOIN ratings r 
    ON r.order_id = ro.order_id 
WHERE ro.pickup_time IS NOT NULL

GROUP BY 
  c.customer_id,
  c.order_id,
  ro.runner_id,
  r.rating, 
  c.order_time,
  ro.pickup_time
ORDER BY order_time  
  ````
  
|customer_id  |order_id|runner_id|rating|order_time|pickup_time|pickup_minutes|avg_speed|number_of_pizzas|
--------------|------------|----------|------|----|------------|----------|------|----|
|101|             1|1       |         3|2020-01-01 18:05:02 |2020-01-01 18:15:34|10|37.50|1|
|101|             2|1       |         5|2020-01-01 19:00:52 | 2020-01-01 19:10:54|10|44.44|1|
|102|             3|1       |         5|2020-01-02 23:51:23 | 2020-01-03 00:12:37|21|40.20|2|
|103|             4|2       |         5|2020-01-04 13:23:46| 2020-01-04 13:53:03|29|35.10|3|
|104|             5|3      |         3|2020-01-08 21:00:29 | 2020-01-08 21:10:57|10|40.00|1|
|105|             7|2       |         2|2020-01-08 21:20:29 | 2020-01-08 21:30:45|10|60.00|1|
|102|             8|2      |         5|2020-01-09 23:54:33 | 2020-01-10 00:15:02|20|93.60|1|
|104|             10|1       |         4|2020-01-11 18:34:49 | 2020-01-11 18:50:20 15|60.00|2|
