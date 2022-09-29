---Part B---
---1.How many customers has Foodie-Fi ever had?---
SELECT DISTINCT customer_id
FROM subscriptions

---2.What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT 
COUNT(p.plan_name),
DATE_TRUNC ('month', s.start_date) AS start_of_the_month
FROM subscriptions s 
INNER JOIN plans p 
ON s.plan_id = p.plan_id
WHERE p.plan_name = 'trial'
GROUP BY DATE_TRUNC ('month', s.start_date), p.plan_name
ORDER BY DATE_TRUNC ('month', s.start_date)

---3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name



SELECT 
plan_name,
COUNT(p.plan_name),
DATE_TRUNC ('year', s.start_date) AS start_of_the_year
FROM subscriptions s 
INNER JOIN plans p 
ON s.plan_id = p.plan_id
WHERE s.start_date > '2020-12-31'
GROUP BY start_of_the_year, p.plan_name
ORDER BY start_of_the_year

---4.What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT
SUM(CASE WHEN p.plan_name = 'churn' THEN 1 ELSE 0 END) AS churn,
ROUND(
100*SUM(CASE WHEN p.plan_id = 4 THEN 1 ELSE 0 END)::NUMERIC/COUNT (DISTINCT s.customer_id), 1 ) AS churn_percentage
FROM subscriptions s 
INNER JOIN plans p ON s.plan_id = p.plan_id


---5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
 
 WITH ranked_plans AS (
 SELECT 
 s.customer_id, 
 p.plan_id,
 p.plan_name,
 ROW_NUMBER () OVER (PARTITION BY s.customer_id 
 ORDER BY s.plan_id) AS plan_rank
 FROM subscriptions s
 INNER JOIN plans p ON s.plan_id = p.plan_id
) 
SELECT
COUNT(*) AS churn_plan,
ROUND(
100*COUNT(*)/ (
    SELECT COUNT(DISTINCT customer_id) 
    FROM subscriptions),0) AS churn_percentage
FROM ranked_plans r
WHERE plan_rank = 2 AND plan_id = 4


---6.What is the number and percentage of customer plans after their initial free trial?

WITH ranked_plans AS (
 SELECT 
 s.customer_id, 
 p.plan_id,
 p.plan_name,
 ROW_NUMBER () OVER (PARTITION BY s.customer_id 
 ORDER BY s.plan_id) AS plan_rank
 FROM subscriptions s
 INNER JOIN plans p ON s.plan_id = p.plan_id
) 
SELECT plan_name,  
COUNT(*) AS customer_count,
ROUND(
100*COUNT(*)/ (
    SELECT COUNT(DISTINCT customer_id) 
    FROM subscriptions),0) AS percentage
FROM ranked_plans 
WHERE plan_rank = 2 
GROUP BY plan_id, plan_name



--- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH 
next_plan AS

(select *, 
			LEAD(start_date, 1) OVER(PARTITION BY customer_id ORDER BY start_date, plan_id) next_date
		from subscriptions
		where start_date <= '20201231'
	) 
		
SELECT n.plan_id, p.plan_name, COUNT (DISTINCT n.customer_id) as number_customers, 
ROUND(100*
COUNT(n.customer_id)::NUMERIC/ (
    SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS percentage
FROM next_plan n
INNER JOIN plans p ON n.plan_id = p.plan_id
WHERE next_date IS NULL
GROUP BY n.plan_id, p.plan_name



---8.How many customers have upgraded to an annual plan in 2020?
SELECT  COUNT (DISTINCT s.customer_id) as annual_members
FROM plans p 
INNER JOIN subscriptions s ON p.plan_id = s.plan_id
WHERE (s.start_date BETWEEN '20200101' AND '20201231') AND s.plan_id = '3'
---9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?


WITH annual_start_date AS (
SELECT s.start_date, p.plan_id, s.customer_id
FROM subscriptions s 
INNER JOIN plans p ON s.plan_id = p.plan_id 
WHERE p.plan_id = '3'
), 
trial_start_date AS (
SELECT s.start_date, p.plan_id, s.customer_id 
FROM subscriptions s 
INNER JOIN plans p ON s.plan_id = p.plan_id 
WHERE p.plan_id = '0'
)
SELECT 
AVG(DATE_PART ('day',  a.start_date::TIMESTAMP - t.start_date::TIMESTAMP)) AS avg_days
FROM annual_start_date a 
INNER JOIN trial_start_date t ON a.customer_id = t.customer_id



---11.How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH ranked_plans AS
(SELECT
  s.customer_id,
  p.plan_id,
  s.start_date,
  LAG(p.plan_id) OVER (
      PARTITION BY s.customer_id
      ORDER BY s.start_date
  ) AS lag_plan_id
FROM subscriptions s 
INNER JOIN plans p ON s.plan_id = p.plan_id
WHERE s.start_date BETWEEN '20200101' AND '20201231'

)
SELECT
  COUNT(DISTINCT customer_id)
FROM lala
WHERE plan_id = 2 AND lag_plan_id = 1


