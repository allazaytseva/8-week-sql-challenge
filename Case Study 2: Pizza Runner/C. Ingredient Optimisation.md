
### 2. What was the most commonly added extra?

````sql
WITh cte_extras AS(
SELECT 
order_id, 
UNNEST(STRING_TO_ARRAY(extras, ','))::INTEGER AS pizza_extras
FROM customer_orders1)

SELECT e.pizza_extras, t.topping_name, COUNT (*) AS number_extras
FROM cte_extras e 
INNER JOIN pizza_toppings t 
ON e.pizza_extras = t.topping_id 
GROUP BY topping_name, pizza_extras
ORDER BY number_extras DESC
````


|pizza_extras|topping_name|number_extras|
--------------|------------|----------|
|             1|Bacon      |         4|
|             5|Chicken      |         1|
|             4|Cheese       |         1|

#### Answer: Bacon

### 3. What was the most common exclusion?

````sql
WITh cte_exc AS(
SELECT 
order_id, 
UNNEST(STRING_TO_ARRAY(exclusions, ','))::INTEGER AS pizza_exc
FROM customer_orders1)

SELECT e.pizza_exc, t.topping_name, COUNT (*) AS number_exc
FROM cte_exc e  
INNER JOIN pizza_toppings t 
ON e.pizza_exc = t.topping_id 
GROUP BY topping_name, pizza_exc
ORDER BY number_exc DESC
````

|pizza_exc|topping_name|number_exc|
--------------|------------|----------|
|             4|Cheese     |         4|
|             6|Mushrooms      |         1|
|             2|BBQ Sauce       |         1|

#### Answer: Cheese
