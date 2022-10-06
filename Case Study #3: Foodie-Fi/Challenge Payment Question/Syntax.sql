DROP TABLE IF EXISTS lead_plans;
CREATE TEMP TABLE lead_p AS
SELECT
	s.customer_id,
	s.plan_id,
	p.plan_name,
	s.start_date payment_date,
	s.start_date,
	LEAD(s.start_date, 1) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) lead_start_date,
	LEAD(p.plan_id, 1) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) lead_plan_id,
	p.price AS amount
FROM subscriptions s
INNER JOIN plans p ON p.plan_id = s.plan_id 
WHERE DATE_PART('year', start_date) = 2020
AND p.plan_id != 0;
		
SELECT * from lead_plans;



DROP TABLE IF EXISTS union_payments;
CREATE TEMP TABLE union_payments AS 

WITH case_1 AS (	
SELECT 
	customer_id,
	plan_id, 
	start_date, 
	DATE_PART ('mon', AGE ('2020-12-31'::DATE, start_date))::INTEGER AS month_diff 
FROM lead_plans
WHERE lead_plan_id IS NULL 
      AND plan_id NOT IN (3,4) 
),
case_1_payments AS (
SELECT 
	customer_id, plan_id,
	(start_date + GENERATE_SERIES (0, month_diff) * INTERVAL '1 month')::DATE AS start_date  
FROM case_1
),
	
case_2 AS (
SELECT 
	customer_id, 
	plan_id,
	start_date,
	DATE_PART ('mon', AGE(lead_start_date - 1, start_date))::INTEGER AS month_diff 
FROM lead_plans
WHERE lead_plan_id = 4
),
case_2_payments AS (
SELECT 
	customer_id, 
	plan_id,
	(start_date +GENERATE_SERIES (0, month_diff)*INTERVAL '1 month')::DATE AS start_date 
FROM case_2
),

case_3 AS ( 
SELECT 
	customer_id, 
	plan_id, 
	start_date, 
	DATE_PART ('mon', AGE (lead_start_date - 1, start_date))::INTEGER AS month_diff
FROM lead_plans
WHERE plan_id = 1 
      AND lead_plan_id IN (2,3) 
),
case_3_payments AS(
SELECT 
	customer_id, 
	plan_id, 
	(start_date + GENERATE_SERIES(0, month_diff)*INTERVAL '1 month' )::DATE as start_date
FROM case_3
),
	
case_4 AS (
SELECT 
	customer_id,
	plan_id, 
	start_date,
	DATE_PART ('mon', AGE(lead_start_date - 1, start_date))::INTEGER AS month_diff
FROM lead_plans 
WHERE plan_id = 2 
      AND lead_plan_id = 3
),

case_4_payments AS (
SELECT 
	customer_id, 
	plan_id, 
	(start_date + GENERATE_SERIES(0, month_diff) * INTERVAL '1 month')::DATE AS start_date 
FROM case_4
), 
	
case_5_payments AS (

SELECT 
	customer_id, 
	plan_id, 
	start_date
FROM lead_plans
WHERE plan_id = 3
)

SELECT * FROM case_1_payments
UNION 
SELECT * FROM case_2_payments
UNION 
SELECT * FROM case_3_payments
UNION 
SELECT * FROM case_4_payments
UNION 
SELECT * FROM case_5_payments
ORDER BY customer_id, start_date;


SELECT * FROM union_payments;



SELECT 
	u.customer_id, 
	u.plan_id, 
	u.start_date AS payment_date, 
	p.plan_name,
	CASE WHEN u.plan_id IN (2,3) AND (LAG(u.plan_id) OVER (PARTITION BY u.customer_id ORDER BY u.start_date) ) = 1
		  THEN p.price - 9.90
		  ELSE p.price END AS amount,
	RANK () OVER (PARTITION BY u.customer_id ORDER BY u.start_date) AS payment_order
FROM union_payments u 
INNER JOIN plans p ON u.plan_id = p.plan_id 
ORDER BY u.customer_id, u.start_date;
