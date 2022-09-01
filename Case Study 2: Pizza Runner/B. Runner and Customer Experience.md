

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)---
SELECT
  DATE_TRUNC('week', registration_date)::DATE + 4 AS registration_week,
  COUNT(*) AS runners
FROM runners
GROUP BY registration_week
ORDER BY registration_week;

#### Answer: 4---

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

WITH cte_pickup_minutes AS (
  SELECT DISTINCT
    r.order_id,
    DATE_PART('minute', AGE(r.pickup_time::TIMESTAMP, c.order_time))::INTEGER AS pickup_minutes
  FROM runner_orders2 AS r
  INNER JOIN customer_orders AS c
    ON r.order_id = c.order_id
  WHERE r.pickup_time IS NOT NULL
)
SELECT
  ROUND(AVG(pickup_minutes), 2) AS avg_pickup_minutes
FROM cte_pickup_minutes;
 ~15 minutes for all of the runners

----without the cte---
SELECT DISTINCT
    r.runner_id,
    AVG(DATE_PART('minute', AGE(r.pickup_time::TIMESTAMP, c.order_time)))::INTEGER AS pickup_minutes
  FROM runner_orders2 AS r
  INNER JOIN customer_orders AS c
    ON r.order_id = c.order_id
  WHERE r.pickup_time IS NOT NULL
  GROUP BY r.runner_id
  ORDER BY runner_id
 runner 1: 15 min, runner 2: 23 min, runner 3: 10min

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?


SELECT corr (number_of_pizzas, pickup_minutes) AS correlation
FROM(
SELECT COUNT (c.order_id) AS number_of_pizzas,
DATE_PART('minute', AGE(r.pickup_time::TIMESTAMP, c.order_time))::INTEGER AS pickup_minutes
FROM runner_orders2 AS r
  INNER JOIN customer_orders AS c
    ON r.order_id = c.order_id
  WHERE r.pickup_time IS NOT NULL
  GROUP BY c.order_id,pickup_minutes) as a
correlation is 0.83 meaning that there's a strong relationship between the number of pizzas and the preparation time

  
SELECT DISTINCT
c.order_id, COUNT (c.order_id) AS number_of_pizzas,
DATE_PART('minute', AGE(r.pickup_time::TIMESTAMP, c.order_time))::INTEGER AS pickup_minutes
FROM runner_orders2 AS r
  INNER JOIN customer_orders AS c
    ON r.order_id = c.order_id
  WHERE r.pickup_time IS NOT NULL
GROUP BY c.order_id, pickup_minutes
ORDER BY pickup_minutes, number_of_pizzas


### 4. What was the average distance travelled for each customer?

SELECT c.customer_id, ROUND(AVG(distance)::NUMERIC,2 ) AS avg_distance
FROM runner_orders2 AS r
  INNER JOIN customer_orders AS c
    ON r.order_id = c.order_id
  WHERE r.pickup_time IS NOT NULL
GROUP BY c.customer_id

---useful function for figuring out data type 
SELECT pg_typeof(distance)
FROM runner_orders2
  
### 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT *
FROM customer_orders1
SELECT *
FROM runner_orders2

SELECT MAX(duration)::NUMERIC - MIN (duration)::NUMERIC
FROM runner_orders2
#### 30min


### 6.What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT runner_id, order_id, distance, 
DATE_PART('hour', pickup_time::TIMESTAMP) AS hour_of_day,
ROUND(AVG(distance::NUMERIC/duration::NUMERIC *60), 2) AS avg_speed
FROM runner_orders2
WHERE distance IS NOT NULL AND duration IS NOT NULL
GROUP BY order_id, runner_id, distance, hour_of_day
ORDER BY runner_id, order_id

#### Answer: Runner 1: avg speed varies from 37.5 - 60 km/h, runner 2's - 35.10 - 93.60 km/h, runner 3 - 40km/h
#### It looks like runner 2 is the fastest, except for his delivery at 1pm – which might be explained by the traffic. 

### 7. What is the successful delivery percentage for each runner?


SELECT runner_id, COUNT (pickup_time), 
ROUND(100 * SUM(CASE WHEN distance IS NULL THEN 0 ELSE 1 END)/COUNT(*), 0) AS deliveries
FROM runner_orders2
GROUP BY runner_id
ORDER BY runner_id;


