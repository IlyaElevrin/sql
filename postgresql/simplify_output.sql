--task - simplify output for the manager (replace id with product names)

WITH prod_id AS (
SELECT order_id, 
UNNEST(product_ids) AS product_id
FROM orders
)
SELECT order_id, 
ARRAY_AGG(name) AS product_names
FROM prod_id AS pi
INNER JOIN products AS p
ON pi.product_id=p.product_id
GROUP BY order_id
LIMIT 1000