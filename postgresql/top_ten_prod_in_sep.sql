--challenge: The 10 most popular items delivered in September 2022

--select a date
WITH date_sep AS (
SELECT order_id
FROM courier_actions
WHERE time >= '2022-09-01'::DATE 
AND time < '2022-10-01'::DATE
AND action='deliver_order'
), 
--selecting unique products
uniq_prod AS (
SELECT order_id, 
ARRAY_AGG(DISTINCT product_id) AS product_ids
FROM (
        SELECT order_id, UNNEST(product_ids) AS product_id
        FROM orders
) AS subarray
WHERE order_id IN 
(SELECT order_id FROM date_sep)
GROUP BY order_id
),
prod_id AS (
SELECT UNNEST(product_ids) AS product_id
FROM uniq_prod
)

SELECT name, 
COUNT(pi.product_id) AS times_purchased
FROM prod_id AS pi
INNER JOIN products AS p
ON pi.product_id=p.product_id
GROUP BY name
ORDER BY times_purchased DESC
LIMIT 10