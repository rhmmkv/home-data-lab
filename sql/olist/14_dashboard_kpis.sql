-- Три отдельных SQL-вопроса Metabase: каждый запрос запускается отдельно.
-- Количество доставленных заказов, доля опозданий и медианная задержка.

SELECT COUNT(*) AS evaluated_orders
FROM olist.orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

SELECT ROUND(
    100.0 * SUM(CASE
        WHEN order_delivered_customer_date::date
            > order_estimated_delivery_date::date THEN 1
        ELSE 0
    END) / COUNT(*), 2
) AS late_delivery_pct
FROM olist.orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

WITH delays AS (
    SELECT order_delivered_customer_date::date
        - order_estimated_delivery_date::date AS days_late
    FROM olist.orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
)
SELECT percentile_cont(0.5)
    WITHIN GROUP (ORDER BY days_late) AS median_days_late
FROM delays
WHERE days_late > 0;
