

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)---
````sql
SELECT
  DATE_TRUNC('week', registration_date)::DATE + 4 AS registration_week,
  COUNT(*) AS runners
FROM runners
GROUP BY registration_week
ORDER BY registration_week;
````

registration_week|runners|
-----------|---------------------------|
2021-01-01          |                          2|
2021-01-08          |                          1|
2021-01-15         |                          1|


#### Answer: 4

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

````sql
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
````

|avg_pickup_minutes|
|----------------|
|15.63|

 #### Answer: ~15 minutes for all of the runners

(without the cte)

````sql
SELECT DISTINCT
    r.runner_id,
    AVG(DATE_PART('minute', AGE(r.pickup_time::TIMESTAMP, c.order_time)))::INTEGER AS pickup_minutes
  FROM runner_orders2 AS r
  INNER JOIN customer_orders AS c
    ON r.order_id = c.order_id
  WHERE r.pickup_time IS NOT NULL
  GROUP BY r.runner_id
  ORDER BY runner_id
````

|runner_id|pickup_minutes|
-----------|---------------------------|
1         |                          15|
2         |                          23|
3        |                          10|


#### Answer: runner 1: 15 min, runner 2: 23 min, runner 3: 10min

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
SELECT corr (number_of_pizzas, pickup_minutes) AS correlation
FROM(
SELECT COUNT (c.order_id) AS number_of_pizzas,
DATE_PART('minute', AGE(r.pickup_time::TIMESTAMP, c.order_time))::INTEGER AS pickup_minutes
FROM runner_orders2 AS r
  INNER JOIN customer_orders AS c
    ON r.order_id = c.order_id
  WHERE r.pickup_time IS NOT NULL
  GROUP BY c.order_id,pickup_minutes) as a
````

|correlation|
|---------|
|0.83725|

#### Comment: correlation is 0.83 meaning that there's a strong relationship between the number of pizzas and the preparation time

 ````sql 
SELECT DISTINCT
c.order_id, COUNT (c.order_id) AS number_of_pizzas,
DATE_PART('minute', AGE(r.pickup_time::TIMESTAMP, c.order_time))::INTEGER AS pickup_minutes
FROM runner_orders2 AS r
  INNER JOIN customer_orders AS c
    ON r.order_id = c.order_id
  WHERE r.pickup_time IS NOT NULL
GROUP BY c.order_id, pickup_minutes
ORDER BY pickup_minutes, number_of_pizzas
````

|order_id|number_of_pizzas|pickup_minutes|
--------------|------------|----------|
|             1|1       |         10|
|             2|1       |         10|
|             5|1       |         10|
|             7|1       |         10|
|             10|2       |         15|
|             8|1       |         20|
|             3|2      |         21|
|             4|3       |         29|


### 4. What was the average distance travelled for each customer?

````sql
SELECT c.customer_id, ROUND(AVG(distance)::NUMERIC,2 ) AS avg_distance
FROM runner_orders2 AS r
  INNER JOIN customer_orders AS c
    ON r.order_id = c.order_id
  WHERE r.pickup_time IS NOT NULL
GROUP BY c.customer_id
````
|customer_id|avg_distance|
|---------|------------|
|101|20.00|
|103|23.40|
|104|10.00|
|105|25.00|
|102|16.73|

Extra:
useful function for figuring out data type

````sql
SELECT pg_typeof(distance)
FROM runner_orders2
````

### 5. What was the difference between the longest and shortest delivery times for all orders?

````sql

SELECT MAX(duration)::NUMERIC - MIN (duration)::NUMERIC AS difference
FROM runner_orders2
````

|difference|
|-------|
|30|

#### Answer: 30min


### 6.What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql
SELECT runner_id, order_id, distance, 
DATE_PART('hour', pickup_time::TIMESTAMP) AS hour_of_day,
ROUND(AVG(distance::NUMERIC/duration::NUMERIC *60), 2) AS avg_speed
FROM runner_orders2
WHERE distance IS NOT NULL AND duration IS NOT NULL
GROUP BY order_id, runner_id, distance, hour_of_day
ORDER BY runner_id, order_id
````
|runner_id|order_id|distance|hour_of_day|
--------------|------------|----------|------|
|             1|1       |         20|18|
|             1|2       |         20|19|
|             1|3       |         13.4|0|
|             1|10       |         10|18|
|             2|4      |         23.4|13|
|             2|7       |         25|21|
|             2|8      |         23.4|0|
|             3|5       |         10|21|

#### Answer: Runner 1: avg speed varies from 37.5 - 60 km/h, runner 2's - 35.10 - 93.60 km/h, runner 3 - 40km/h
#### It looks like runner 2 is the fastest, except for his delivery at 1pm – which might be explained by the traffic. 

### 7. What is the successful delivery percentage for each runner?

````sql
SELECT runner_id, COUNT (pickup_time), 
ROUND(100 * SUM(CASE WHEN distance IS NULL THEN 0 ELSE 1 END)/COUNT(*), 0) AS deliveries
FROM runner_orders2
GROUP BY runner_id
ORDER BY runner_id;
````

|runner_id|count|deliveries|
--------------|------------|----------|
|             1|4       |         100|
|             2|3       |         75|
|             3|1       |         50|

#### Answer: Runner 1: 100%, runner 2: 75, runner 3: 50
