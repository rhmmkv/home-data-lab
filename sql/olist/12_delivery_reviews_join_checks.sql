-- Проверка сохранения заказов и уникальности после LEFT JOIN с отзывами.
-- Выборка: delivered с обеими датами. Ожидаемая дата имеет время 00:00.

WITH cte AS (
    SELECT *,
        MAX(t.review_answer_timestamp) OVER (
            PARTITION BY t.order_id
        ) AS max_rats
    FROM olist.order_reviews t
),
cte1 AS (
    SELECT *,
        CASE
            WHEN EXTRACT(EPOCH FROM
                (o.order_estimated_delivery_date + INTERVAL '1 day')
                - o.order_delivered_customer_date) > 0 THEN 'ontime'
            WHEN EXTRACT(EPOCH FROM
                (o.order_estimated_delivery_date + INTERVAL '1 day')
                - o.order_delivered_customer_date) <= 0 THEN 'late'
        END AS punctuality
    FROM olist.orders o
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
    COUNT(*) AS rows_count,
    COUNT(DISTINCT cte1.order_id) AS orders_count,
    COUNT(cte.review_score) AS with_score
FROM cte1
LEFT JOIN cte
    ON cte1.order_id = cte.order_id
   AND cte.review_answer_timestamp = cte.max_rats
;
