-- Границы периода, количество заказов по месяцам и сверка общего итога.
-- Все статусы; отсутствующие месяцы не добавляются в календарный ряд.

SELECT
    min(o.order_purchase_timestamp) AS first_purchase,
    max(o.order_purchase_timestamp) AS last_purchase
FROM olist.orders o;

SELECT
    to_char(o.order_purchase_timestamp, 'YYYY-MM') AS order_purchase,
    count(o.order_purchase_timestamp) AS orders_count
FROM olist.orders o
GROUP BY to_char(o.order_purchase_timestamp, 'YYYY-MM')
ORDER BY 1;

SELECT sum(orders_count) AS total_orders_from_months
FROM (
    SELECT
        to_char(o.order_purchase_timestamp, 'YYYY-MM') AS order_purchase,
        count(o.order_purchase_timestamp) AS orders_count
    FROM olist.orders o
    GROUP BY to_char(o.order_purchase_timestamp, 'YYYY-MM')
    ORDER BY 1
) AS t1;
