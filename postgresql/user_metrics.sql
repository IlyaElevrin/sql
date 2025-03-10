--clearing out canceled orders
WITH cancel_ord_id AS (
SELECT order_id
FROM user_actions
WHERE action='cancel_order'
),
count_orders_and_avg_count_products AS (
SELECT u.user_id, 
COUNT(u.order_id) AS orders_count, 
AVG(array_length(o.product_ids, 1)) AS avg_order_size,
u.order_id
FROM orders AS o 
RIGHT JOIN user_actions AS u 
ON o.order_id=u.order_id
WHERE u.order_id NOT IN 
(SELECT order_id FROM cancel_ord_id)
GROUP BY u.user_id, u.order_id
ORDER BY u.user_id ASC
),
--split the array of products in the order into separate items
prod_id AS (
SELECT order_id,
UNNEST(product_ids) AS product_id
FROM orders
WHERE order_id NOT IN 
(SELECT order_id FROM cancel_ord_id)
),
--price your orders
price_prod AS (
select order_id, 
SUM(price) sum_order_value
FROM prod_id AS pi 
INNER JOIN products AS p 
ON pi.product_id=p.product_id
GROUP BY order_id
),
--join the above tables
all_three AS (
SELECT pp.order_id,
user_id, 
COUNT(orders_count) AS orders_count, 
AVG(avg_order_size) AS avg_order_size,
SUM(sum_order_value) AS sum_order_value
FROM count_orders_and_avg_count_products AS cocp
LEFT JOIN price_prod AS pp
ON cocp.order_id=pp.order_id
GROUP BY user_id, pp.order_id
ORDER BY user_id ASC
),
sum_price_order AS (
SELECT order_id, 
SUM(price) AS avg_order_value
FROM prod_id AS pi 
INNER JOIN products AS p
ON pi.product_id=p.product_id
GROUP BY order_id
),
avg_order_value AS (
SELECT user_id, avg(avg_order_value) avg_order_value
FROM sum_price_order AS apo
right JOIN user_actions AS ua
ON apo.order_id=ua.order_id
WHERE ua.order_id NOT IN (SELECT order_id FROM cancel_ord_id)
GROUP BY user_id
ORDER BY user_id
),
--join the above tables
all_four as (
SELECT al.user_id, 
count(orders_count) AS orders_count, 
avg(avg_order_size) AS avg_order_size,
SUM(sum_order_value) AS sum_order_value,
avg(avg_order_value) AS avg_order_value
FROM all_three AS al
INNER JOIN avg_order_value AS av
ON al.user_id=av.user_id
GROUP BY al.user_id
ORDER BY user_id asc
),
min_max_order_value AS (
SELECT user_id, 
min(avg_order_value) AS min_order_value,
max(avg_order_value) AS max_order_value
FROM sum_price_order AS apo
RIGHT JOIN user_actions AS ua
ON apo.order_id=ua.order_id
WHERE ua.order_id NOT IN (SELECT order_id FROM cancel_ord_id)
GROUP BY user_id
ORDER BY user_id
)

--resulting query
SELECT mm.user_id, 
orders_count,
round(avg_order_size, 2) AS avg_order_size, 
round(sum_order_value, 2) AS sum_order_value, 
round(avg_order_value, 2) AS avg_order_value,
round(min_order_value, 2) AS min_order_value, 
round(max_order_value, 2) AS max_order_value
FROM all_four AS al
INNER JOIN min_max_order_value AS mm
ON al.user_id=mm.user_id
LIMIT 1000