-- Количество оформленных заказов по дням за август–октябрь 2018 года.
-- Все статусы; дни без заказов не добавляются в результат.

SELECT
    to_char(o.order_purchase_timestamp, 'YYYY-MM-DD') AS order_purchase,
    count(o.order_purchase_timestamp) AS orders_count
FROM olist.orders o
WHERE to_char(o.order_purchase_timestamp, 'YYYY-MM')
    BETWEEN '2018-08' AND '2018-10'
GROUP BY to_char(o.order_purchase_timestamp, 'YYYY-MM-DD')
ORDER BY 1;
