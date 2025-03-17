--task - share of canceled orders by gender

--metric “share of canceled orders for each user”
WITH cancel_rate AS (
SELECT user_id,
    ROUND(COUNT(action)
        FILTER (WHERE action = 'cancel_order')::DECIMAL / (COUNT(action)::DECIMAL - COUNT(action) 
        FILTER (WHERE action = 'cancel_order')::DECIMAL),
        2) as cancel_rate
FROM user_actions
GROUP BY user_id
ORDER BY user_id
)
--for each gender
SELECT COALESCE(sex, 'unknown') AS sex,  ROUND(AVG(cancel_rate), 3) AS avg_cancel_rate
FROM cancel_rate AS cr
FULL JOIN users AS a
ON cr.user_id=a.user_id
GROUP BY sex
ORDER BY sex ASC