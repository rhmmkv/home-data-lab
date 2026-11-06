-- Последний известный ответ покупателя по максимальному времени ответа.
-- Совпадения максимального времени могут дать несколько строк на заказ;
-- второй запрос проверяет уникальность выбранных заказов.

WITH cte AS (
    SELECT *,
        MAX(t.review_answer_timestamp) OVER (
            PARTITION BY t.order_id
        ) AS max_rats
    FROM olist.order_reviews t
)
SELECT order_id, review_id, review_score, review_answer_timestamp
FROM cte
WHERE review_answer_timestamp = max_rats;

WITH cte AS (
    SELECT *,
        MAX(t.review_answer_timestamp) OVER (
            PARTITION BY t.order_id
        ) AS max_rats
    FROM olist.order_reviews t
)
SELECT
    COUNT(*) AS rows_count,
    COUNT(DISTINCT order_id) AS orders_count
FROM cte
WHERE review_answer_timestamp = max_rats;
