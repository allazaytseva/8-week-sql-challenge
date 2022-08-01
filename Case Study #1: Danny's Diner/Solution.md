


### Bonus Questions:

11. Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)


````sql
SELECT s.customer_id, s.order_date, m.product_name, m.price, m2.join_date,
  CASE WHEN s.order_date >= m2.join_date THEN 'Y'
  ELSE 'N' END AS member_notmember
  FROM sales s 
  LEFT JOIN menu m
  ON  s.product_id = m.product_id 
  LEFT JOIN members m2
  ON m2.customer_id = s.customer_id 
````

| customer_id | order_date | product_name | price| join_date | member_notmember |
| ----------- | ---------- | ------------ | ---- | --------- | ---------------- |
|A            | 2021-01-01 | sushi       |   10 | 2021-01-07 | N               |
|A          | 2021-01-01 | curry       |   15|2021-01-07|N               |
|A          | 2021-01-07 | curry       |   15|2021-01-07|Y               |
|A          | 2021-01-10 | ramen       |   12|2021-01-07|Y               |
|A          | 2021-01-11 | ramen       |   12|2021-01-07|Y               |
|A          | 2021-01-11 | ramen       |   12|2021-01-07|Y               |
|B          | 2021-01-01 | curry       |   15|2021-01-09|N               |
|B          | 2021-01-02 | curry       |   15|2021-01-09|N               |
|B          | 2021-01-04 | sushi       |   10|2021-01-09|N               |
|B          | 2021-01-11 | sushi       |   10|2021-01-09|Y               |
|B          | 2021-01-16 | ramen       |   12|2021-01-09|Y               |
|B          | 2021-02-01 | ramen       |   12|2021-01-09|Y               |
|C          | 2021-01-01 | ramen       |   12|          |N               |
|C          | 2021-01-01 | ramen       |   12|          |N               |
|C          | 2021-01-07 | ramen       |   12|          |N               |
