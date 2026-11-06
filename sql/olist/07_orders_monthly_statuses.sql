-- Заказы по месяцу оформления и статусу, записанному в выгрузке.
-- Статус не является историей переходов заказа между состояниями.

SELECT
    to_char(o.order_purchase_timestamp, 'YYYY-MM') AS order_purchase_month,
    o.order_status,
    count(o.order_purchase_timestamp) AS orders_count
FROM olist.orders o
GROUP BY
    to_char(o.order_purchase_timestamp, 'YYYY-MM'),
    o.order_status
ORDER BY 1;
