-- Доля опозданий среди delivered с обеими датами.
-- Следующий день после обещанной даты включается в опоздание.
-- Предполагается время 00:00 в order_estimated_delivery_date.

WITH cte AS (
    SELECT count(*) AS latecomers
    FROM (
        SELECT extract(epoch FROM
            (o.order_estimated_delivery_date + interval '1 day')
            - o.order_delivered_customer_date
        ) AS diff_date
        FROM olist.orders o
        WHERE o.order_status = 'delivered'
          AND o.order_delivered_customer_date IS NOT NULL
          AND o.order_estimated_delivery_date IS NOT NULL
    ) AS t1
    WHERE t1.diff_date <= 0
)
SELECT
    count(*) AS all_dilivered,
    (SELECT latecomers FROM cte) AS latecomers,
    ((SELECT latecomers FROM cte)::numeric / count(*)) * 100
        AS rate_latecomers
FROM olist.orders o
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL;
