## Challenge Payment Question

#### Context: 

The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments

We need to create a table that would contain the detailed information about customers and their subscription payments that reflect how much they actually paid and not just the cost of the subscription. This solution is part of the guided project from the [8-week SQL challenge](https://8weeksqlchallenge.com/getting-started/) brought by Danny Ma and the Data With Danny virtual data apprenticeship program. It took me a couple of days to figure out how this problem is solved and debug Danny's solution code. 

Here's the solution that was a bit modified and broken down in pieces in case someone else is also sitting down and struggling to understand the code!

My solution consists of 3 parts. 


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

PART 2.

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
	
	SELECT customer_id,
	plan_id, 
	start_date, 
	DATE_PART ('mon', AGE ('2020-12-31'::DATE, start_date))::INTEGER AS month_diff --- they never canceled their subscription, that's why we're subtracting the start date from the last day of 2020
	FROM lead_plans 
	WHERE lead_plan_id IS NULL --- as we mentioned before, null values mean the subscription was not cdhanged in 2020
	AND plan_id NOT IN (3,4) --- we're not including customers who either canceled their subscriptions (we'll take them as the next case) or switched to the annual pro plan (also in the next case)
	)
	---case_1_payments 
	SELECT 
	customer_id, plan_id,
	(start_date + GENERATE_SERIES (0, month_diff) * INTERVAL '1 month')::DATE AS start_date  ---generate_series will help us break down the time the customer is subscribed into months and record the beginning of every month 
	FROM case_1
````


 
