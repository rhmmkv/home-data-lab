-- Наличие фактической даты доставки по статусу заказа.

SELECT
    o.order_status,
    count(*) AS all_orders,
    count(o.order_delivered_customer_date) AS with_delivery_date
FROM olist.orders o
GROUP BY o.order_status;
