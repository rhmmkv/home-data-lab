-- Медианная задержка среди опоздавших заказов, в календарных днях.

WITH cte1 AS (
    SELECT
        o.order_delivered_customer_date::date
            - o.order_estimated_delivery_date::date AS days_late
    FROM olist.orders o
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY days_late)
FROM cte1
WHERE days_late > 0;
