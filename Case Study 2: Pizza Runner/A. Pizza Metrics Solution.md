## Case Study Questions

### 1. How many pizzas were ordered?

````sql
SELECT COUNT (order_id) AS pizzas_ordered
FROM customer_orders1;
````
| pizzas_ordered|
| ------------- |
| 14            |

#### Answer: 14


### 2.How many unique customer orders were made?
````sql
SELECT COUNT (DISTINCT order_id) AS unique_customers
FROM customer_orders1;
````
| unique_customers|
| ------------- |
| 10            |

#### Answer: 10

### 3. How many successful orders were delivered by each runner?
````sql
SELECT runner_id, COUNT(DISTINCT order_id) AS successful_deliveries
FROM runner_orders2
WHERE distance != 'null'
GROUP BY runner_id;

````
|runner_id |successful_deliveries| 
|----------- | ---- | 
|1           |  4|        
|2           |  3|        
|3           |  1|         

#### Answer: 1: 4, 2: 3, 3: 1
 
### 4. How many of each type of pizza was delivered?


````sql
SELECT COUNT ( c.pizza_id), p.pizza_name
FROM customer_orders1 c
JOIN runner_orders2 r ON c.order_id = r.order_id
JOIN pizza_names p ON c.pizza_id = p.pizza_id
WHERE r.distance IS NOT NULL
GROUP BY p.pizza_name
````
|count |pizza_name| 
|----------- | ---- | 
|9          |  Meatlovers|        
|3           |  Vegetarian|        

#### Answer: Meatlovers: 9, Vegetarian: 3

### 5. How many Vegetarian and Meatlovers were ordered by each customer?
````sql
SELECT COUNT (c.pizza_id), p.pizza_name, c.customer_id
FROM customer_orders1 c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id
````
---COUNT (c.pizza_id)|pizza_name|customer_id|
------------------+----------+-----------+
 ---                2|Meatlovers|        101|
 ---                1|Vegetarian|        101|
 ---               2|Meatlovers|        102|
 ---                1|Vegetarian|        102|
 ---                3|Meatlovers|        103|
 ---                 1|Vegetarian|        103|
 ---                3|Meatlovers|        104|
 ---                1|Vegetarian|        105|


### 6.What was the maximum number of pizzas delivered in a single order?

````sql
WITH pizza_count AS(

SELECT COUNT(c.pizza_id) AS pizza_per_order
FROM customer_orders1 c
JOIN runner_orders2 r ON c.order_id = r.order_id
WHERE r.distance IS NOT NULL
GROUP BY c.order_id)

SELECT MAX(pizza_per_order)
FROM pizza_count
````

#### Answer: 3


### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
SELECT 
  c.customer_id,
  SUM(
    CASE WHEN c.exclusions IS NOT NULL OR c.extras IS NOT NULL THEN 1
    ELSE 0
    END) AS with_changes,
  SUM(
    CASE WHEN c.exclusions IS NULL AND c.extras IS NULL THEN 1 
    ELSE 0
    END) AS no_change
FROM customer_orders1 c
JOIN runner_orders2 r
  ON c.order_id = r.order_id
WHERE r.distance IS NOT NULL
GROUP BY c.customer_id
ORDER BY c.customer_id;
````

### 8. How many pizzas were delivered that had both exclusions and extras?

````sql
SELECT 
c.customer_id, 
SUM(
  CASE WHEN c.exclusions IS NOT NULL AND c.extras IS NOT NULL THEN 1
  ELSE 0
  END) AS number_mp
FROM customer_orders1 c
JOIN runner_orders2 r
  ON c.order_id = r.order_id
WHERE r.distance IS NOT NULL
AND exclusions IS NOT NULL 
AND extras IS NOT NULL
GROUP BY c.customer_id
````

#### Answer: One pizza had both exclusions and extras 

### 9.What was the total volume of pizzas ordered for each hour of the day?

````sql
SELECT 
DATE_PART('hour', order_time::TIMESTAMP) AS hour_of_day, 
COUNT (order_id) as pizzas_ordered
FROM customer_orders1
GROUP BY hour_of_day
ORDER BY hour_of_day
````
#### Answer: 11h: 1, 13: 3, 18: 3, 19: 1, 21: 3, 23: 3

### 10. What was the volume of orders for each day of the week?

````sql
SELECT
  TO_CHAR(order_time, 'Day') AS day_of_week, ---to_char converts timestamp here to a string character---
  COUNT(order_id) AS pizza_count, 
  ROUND (100*COUNT(order_id)/SUM(COUNT(order_id)) over(), 2) AS volume_of_pizzas
FROM customer_orders1
GROUP BY day_of_week, DATE_PART('dow', order_time) ---extracting day of the week---
ORDER BY DATE_PART('dow', order_time);
````



