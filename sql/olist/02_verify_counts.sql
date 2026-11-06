-- Read-only row-count comparison. Expected values are from data/sources.json.
-- This checks import completeness, not keys, joins, or analytical data quality.

WITH expected (table_name, expected_rows) AS (
    VALUES
        ('customers', 99441::bigint),
        ('geolocation', 1000163::bigint),
        ('order_items', 112650::bigint),
        ('order_payments', 103886::bigint),
        ('order_reviews', 99224::bigint),
        ('orders', 99441::bigint),
        ('products', 32951::bigint),
        ('sellers', 3095::bigint),
        ('product_category_name_translation', 71::bigint)
), actual (table_name, actual_rows) AS (
    SELECT 'customers', count(*) FROM olist.customers
    UNION ALL
    SELECT 'geolocation', count(*) FROM olist.geolocation
    UNION ALL
    SELECT 'order_items', count(*) FROM olist.order_items
    UNION ALL
    SELECT 'order_payments', count(*) FROM olist.order_payments
    UNION ALL
    SELECT 'order_reviews', count(*) FROM olist.order_reviews
    UNION ALL
    SELECT 'orders', count(*) FROM olist.orders
    UNION ALL
    SELECT 'products', count(*) FROM olist.products
    UNION ALL
    SELECT 'sellers', count(*) FROM olist.sellers
    UNION ALL
    SELECT 'product_category_name_translation', count(*)
    FROM olist.product_category_name_translation
)
SELECT
    expected.table_name,
    actual.actual_rows,
    expected.expected_rows,
    actual.actual_rows = expected.expected_rows AS matches
FROM expected
JOIN actual USING (table_name)
ORDER BY expected.table_name;
