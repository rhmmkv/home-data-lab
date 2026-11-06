-- Уникальность order_id и заполненность идентификатора и даты оформления.

SELECT
    count(*) AS total_rows,
    count(DISTINCT order_id) AS unique_order_ids,
    count(*) - count(o.order_id) AS missing_order_ids,
    count(*) - count(o.order_purchase_timestamp) AS missing_purchase_dates
FROM olist.orders o;

SELECT count(*) AS missing_purchase_dates
FROM olist.orders o
WHERE order_purchase_timestamp IS NULL;
