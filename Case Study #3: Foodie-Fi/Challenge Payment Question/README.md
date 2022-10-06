## Challenge Payment Question

#### Context: 

The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments

We need to create a table that would contain the detailed information about customers and their subscription payments that reflect how much they actually paid and not just the cost of the subscription. This solution is part of the guided project from the [8-week SQL challenge](https://8weeksqlchallenge.com/getting-started/) brought by Danny Ma and the Data With Danny virtual data apprenticeship program. It took me a couple of days to figure out how this problem is solved and debug Danny's solution code. Here's the solution broken down in pieces in case someone else is also sitting down and struggling to understand the code!


