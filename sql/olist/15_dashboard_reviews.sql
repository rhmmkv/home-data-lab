-- Сравнение оценок для графика и таблицы Metabase.
-- Правила SQL 13, русские названия групп и сортировка строк.

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
    CASE punctuality
        WHEN 'ontime' THEN 'Вовремя'
        WHEN 'late' THEN 'Опоздали'
    END AS delivery_group,
    COUNT(*) AS count_with_review,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    SUM(
        CASE WHEN review_score IN (1, 2) THEN 1 ELSE 0 END
    ) AS low_score_count,
    ROUND(
        100.0 * SUM(
            CASE WHEN review_score IN (1, 2) THEN 1 ELSE 0 END
        ) / COUNT(*), 2
    ) AS low_score_pct
FROM cte1
LEFT JOIN cte
    ON cte1.order_id = cte.order_id
   AND cte.review_answer_timestamp = cte.max_rats
WHERE cte.review_score IS NOT NULL
GROUP BY punctuality
ORDER BY delivery_group;
