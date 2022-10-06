## Challenge Payment Question

#### Context: 

The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments

We need to create a table that would contain the detailed information about customers and their subscription payments that reflect how much they actually paid and not just the cost of the subscription. This solution is part of the guided project from the [8-week SQL challenge](https://8weeksqlchallenge.com/getting-started/) brought by Danny Ma and the Data With Danny virtual data apprenticeship program. It took me a couple of days to figure out how this problem is solved and debug Danny's solution code. 

Here's the solution that was a bit modified and broken down in pieces in case someone else is also sitting down and struggling to understand the code!

My solution consists of 4 parts. 


#### Part 1. 

First we are going to create a temporary table *lead_plans* that we'll be working with for the rest of the problem. Here, we will run the **LEAD window function** on *start_date* and *plan_id* that will create a table with records of what plans customers have and whether they switch to a different and when. The *null* values mean that the plan hasn't changed. We have filtered out all trial plans (plan_id = 0) as this plan is free and we're not interested in it. We are also only interested in year 2020. 

````sql
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
AND p.plan_id != 0
		
		SELECT * from lead_plans
````

#### Part 2.

In his solution, Danny divided all customers in logical groups: 
- case 1: non churn monthly customers
- case 2: churn customers
- case 3: customers who move from basic to pro plans
- case 4: pro monthly customers who move up to annual plans
- case 5: annual pro payments

We are going to look at each case separately and after that we'll union all of them in a temp table to use later. 

**Case 1: non-churn monthly users**

````sql
WITH case_1 AS (
	
SELECT 
	customer_id,
	plan_id, 
	start_date, 
	DATE_PART ('mon', AGE ('2020-12-31'::DATE, start_date))::INTEGER AS month_diff 
FROM lead_plans 
WHERE lead_plan_id IS NULL 
      AND plan_id NOT IN (3,4) 
)
	---case_1_payments 
SELECT 
	customer_id, 
	plan_id,
	(start_date + GENERATE_SERIES (0, month_diff) * INTERVAL '1 month')::DATE AS start_date   
FROM case_1
````
- We are using ```DATE_PART``` to extract months from the date and ```AGE``` to count the difference in months between the last day of 2020 and customers basic monthly subscription date. We are using the last day of the year since customers never canceled the subscription. 
- We are filtering out everything in the lead_plan_id column except for the null values, meaning there's no next date or plan subscription for the particular customer in 2020
- ```plan_id``` is either basic monthly or pro monthly as this is what we are interested in in this case
- ```GENERATE_SERIES``` will help us break down the time the customer is subscribed into months and record the beginning of every month
 
**Case 2: churn customers**

Here we are looking at churn_customers that paid for the subscription before they decided to cancel it

````sql

WITH case_2 AS (
SELECT customer_id, 
plan_id,
start_date,
DATE_PART ('mon', AGE(lead_start_date - 1, start_date))::INTEGER AS month_diff 
FROM lead_plans
WHERE lead_plan_id = 4
) 
SELECT 
customer_id, plan_id,
(start_date +GENERATE_SERIES (0, month_diff)*INTERVAL '1 month')::DATE AS start_date 
FROM case_2
````
- The only difference here is the ```AGE``` function where we are looking at the ```lead_start_date``` and we need to subtract 1 (month) because the customer was still paying for the previous plan and we need to take that into account

**Case 3: customers who move from basic to pro plans**

````sql
WITH case_3 AS (
SELECT 
	customer_id, 
	plan_id, 
	start_date, 
	DATE_PART ('mon', AGE (lead_start_date - 1, start_date))::INTEGER AS month_diff
FROM lead_plans
WHERE plan_id = 1 AND lead_plan_id IN (2,3) 
)
SELECT customer_id, 
plan_id, 
(start_date + GENERATE_SERIES(0, month_diff)*INTERVAL '1 month' )::DATE as start_date
FROM case_3
````
- ```WHERE plan_id = 1 AND lead_plan_id IN (2,3)``` we're filtering these plans to show that first the customer had a basic monthly subscription, and then the customer upgraded to either pro monthly or pro annual and we need to consider this upgrade for the correct payment record

**Case 4: pro monthly customers who move up to annual plans**

````sql
WITH case_4 AS (
SELECT 
	customer_id,
	plan_id, 
	start_date,
	DATE_PART ('mon', AGE(lead_start_date - 1, start_date))::INTEGER AS month_diff
FROM lead_plans 
WHERE plan_id = 2 AND lead_plan_id = 3
)
SELECT 
customer_id, 
plan_id, 
(start_date + GENERATE_SERIES(0, month_diff) * INTERVAL '1 month')::DATE AS start_date 
FROM case_4
````
- Same as before, but here we're filtering out the initial plan_id=2 and the next plan_id = 3 which shows the upgrade from a pro monthly plan to a pro annual plan

**Case 5: pro annual customers** 
Pro annual plan does not need to be broken down into months as the annual payment happens once a year.

````sql
SELECT customer_id, 
plan_id, 
start_date
FROM lead_plans
WHERE plan_id = 3
````

#### Part 4. 

Now we are going to ```UNION``` all of the cases, but before that we need to create a temp table with all these cases as window functions. Here's what we've got: 

````sql

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
ORDER BY customer_id, start_date


SELECT * FROM union_payments

````

#### Part 4. 

In this part, we are going to make the corrections in the amount that the customers have paid for their plans. What we need to remember is that upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately. Upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period.

````sql

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
ORDER BY u.customer_id, u.start_date
````
- We are using the ```LAG``` function here to track the change in the subscription. When the customer upgrades from a basic plan to a monthly or pro plans, they get the basic plan cost back and the new plan subscription starts immeditely. 
- ```RANK () OVER```to keep track of payment orders for each customer. 


|customer_id|plan_id| payment_date| plan_name| amount| payment_order|
|------|-----|----------|-------|----------|-----|
|1 | 1 | 2020-08-08 | basic monthly | 9.90 | 1|
|1 | 1 | 2020-09-08 | basic monthly | 9.90 | 2|
|1 | 1 | 2020-10-08| basic monthly  | 9.90 | 3|
|1 | 1 | 2020-11-08| basic monthly  | 9.90 | 4|
|1 | 1 | 2020-12-08 | basic monthly | 9.90 | 5|
|2 | 3 | 2020-09-27| pro annual  | 199.00 | 1|
|… | … | … | … |… |…|
|8 | 1 | 2020-06-18 | basic monthly | 9.90 | 1|
|8 | 1 | 2020-07-18 | basic monthly | 9.90 | 2|
|8 | 2 | 2020-08-03| pro monthly  | 10.00 | 3|
|8 | 2 | 2020-09-03| pro  monthly  | 19.90 | 4|
|8 | 2 | 2020-10-03 | pro monthly | 19.90 | 5|
|8 | 2 | 2020-11-03| pro monthly  | 19.90 | 6|
|8 | 2 | 2020-12-03 | pro monthly | 19.90 | 7|
|… | … | … | … |… |…|
|51 | 1 | 2020-01-26 | basic monthly | 9.90 | 5|
|51 | 1 | 2020-02-26| basic monthly  | 9.90 | 6|
|51 | 3 | 2020-03-09 | pro annual | 199.10 | 7|
