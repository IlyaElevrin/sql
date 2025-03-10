--clearing out canceled orders
WITH cancel_ord_id AS (
SELECT order_id
FROM user_actions
WHERE action='cancel_order'
),
--split the array of products in the order into separate items
rod_id AS (
SELECT creation_time,
UNNEST(product_ids) AS product_id
FROM orders
WHERE order_id NOT IN 
(SELECT order_id FROM cancel_ord_id)
)

SELECT DATE_TRUNC('day', ri.creation_time)::DATE AS date, 
SUM(p.price) AS revenue
FROM rod_id AS ri
INNER JOIN products AS p
ON p.product_id=ri.product_id
GROUP BY DATE_TRUNC('day', ri.creation_time)
ORDER BY date ASC