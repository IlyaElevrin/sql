with count_orders_and_avg_count_products as (
select u.user_id, 
count(u.order_id) as orders_count, 
avg(array_length(o.product_ids, 1)) as avg_order_size,
u.order_id
from orders o 
right join user_actions u 
on o.order_id=u.order_id
group by u.user_id, u.order_id
order by u.user_id asc
),
prod_id as (
select order_id,
unnest(product_ids) product_id
from orders
),
price_prod as (
select order_id, 
sum(price) sum_order_value
from prod_id as pi 
inner join products as p 
on pi.product_id=p.product_id
group by order_id
),
---первые три
all_three as (
select pp.order_id,
user_id, 
count(orders_count) as orders_count, 
avg(avg_order_size) avg_order_size,
sum(sum_order_value) sum_order_value
from count_orders_and_avg_count_products as cocp
left join price_prod as pp
on cocp.order_id=pp.order_id
group by user_id, pp.order_id
order by user_id asc
),
sum_price_order as (
select order_id, 
sum(price) as avg_order_value
from prod_id pi 
inner join products p
on pi.product_id=p.product_id
group by order_id
),
avg_order_value as (
select user_id, avg(avg_order_value) avg_order_value
from sum_price_order as apo
right join user_actions as ua
on apo.order_id=ua.order_id
group by user_id
order by user_id