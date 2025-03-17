--task - top ten orders with the longest shipping time

--
WITH deliv_ord AS (
SELECT order_id
FROM courier_actions
WHERE action = 'deliver_order'
),
time AS (
SELECT o.order_id AS order_id, 
MAX(time) - MIN(creation_time) AS time_delivery
FROM orders AS o
INNER JOIN courier_actions AS ca
ON o.order_id=ca.order_id
WHERE o.order_id IN 
(SELECT order_id FROM deliv_ord)
GROUP BY o.order_id
ORDER BY time_delivery DESC
)

SELECT order_id
FROM time
LIMIT 10