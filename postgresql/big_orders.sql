--task - who ordered and delivered the biggest orders

WITH del_ord AS (
SELECT order_id
FROM courier_actions
WHERE action='deliver_order'
),
--bind to c.a.
id_cour_act AS (
SELECT o.order_id AS order_id, 
ARRAY_LENGTH(product_ids, 1) AS array_length,
courier_id,
time
FROM orders AS o
LEFT JOIN courier_actions AS c
ON o.order_id=c.order_id
WHERE o.order_id IN 
(SELECT order_id FROM del_ord)
),
--age cour
id_cour AS (
SELECT order_id,
array_length,
ica.courier_id,
AGE(time, birth_date) AS courier_age
FROM id_cour_act AS ica
INNER JOIN couriers AS c
ON ica.courier_id=c.courier_id
),
--bind to u.a.
id_us_act AS (
SELECT ic.order_id,
array_length,
courier_id,
courier_age,
user_id,
time
FROM id_cour AS ic
INNER JOIN user_actions AS ua
ON ic.order_id=ua.order_id
),
--age cour
id_us AS (
SELECT order_id,
AVG(array_length) AS array_length,
AVG(courier_id)::INT AS courier_id,
EXTRACT(YEAR FROM AVG(courier_age))::INT AS courier_age,
AVG(iua.user_id)::INT AS user_id,
EXTRACT(YEAR FROM AVG(AGE(time, birth_date)))::INT AS user_age
FROM id_us_act AS iua
INNER JOIN users AS u
ON iua.user_id=u.user_id
GROUP BY order_id
ORDER BY array_length DESC
LIMIT 5
)

SELECT order_id, 
courier_id,
courier_age,
user_id,
user_age
FROM id_us
ORDER BY order_id ASC