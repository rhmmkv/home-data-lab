-- Home Data Lab: tables for the original Olist CSV files.
-- Run in home_data_lab as lab_admin with psql ON_ERROR_STOP=1.
-- This script creates empty tables; CSV import is a separate step.

BEGIN;

CREATE SCHEMA olist AUTHORIZATION lab_admin;

CREATE TABLE olist.customers (
    customer_id text,
    customer_unique_id text,
    customer_zip_code_prefix text,
    customer_city text,
    customer_state text
);

CREATE TABLE olist.geolocation (
    geolocation_zip_code_prefix text,
    geolocation_lat double precision,
    geolocation_lng double precision,
    geolocation_city text,
    geolocation_state text
);

CREATE TABLE olist.order_items (
    order_id text,
    order_item_id integer,
    product_id text,
    seller_id text,
    shipping_limit_date timestamp without time zone,
    price numeric,
    freight_value numeric
);

CREATE TABLE olist.order_payments (
    order_id text,
    payment_sequential integer,
    payment_type text,
    payment_installments integer,
    payment_value numeric
);

CREATE TABLE olist.order_reviews (
    review_id text,
    order_id text,
    review_score smallint,
    review_comment_title text,
    review_comment_message text,
    review_creation_date timestamp without time zone,
    review_answer_timestamp timestamp without time zone
);

CREATE TABLE olist.orders (
    order_id text,
    customer_id text,
    order_status text,
    order_purchase_timestamp timestamp without time zone,
    order_approved_at timestamp without time zone,
    order_delivered_carrier_date timestamp without time zone,
    order_delivered_customer_date timestamp without time zone,
    order_estimated_delivery_date timestamp without time zone
);

-- Keep the source column spelling ("lenght") to match the CSV.
CREATE TABLE olist.products (
    product_id text,
    product_category_name text,
    product_name_lenght integer,
    product_description_lenght integer,
    product_photos_qty integer,
    product_weight_g integer,
    product_length_cm integer,
    product_height_cm integer,
    product_width_cm integer
);

CREATE TABLE olist.sellers (
    seller_id text,
    seller_zip_code_prefix text,
    seller_city text,
    seller_state text
);

CREATE TABLE olist.product_category_name_translation (
    product_category_name text,
    product_category_name_english text
);

-- Grant the existing analysis role read access to these tables.
GRANT USAGE ON SCHEMA olist TO analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA olist TO analyst;

-- Keys and other data constraints will follow data quality checks.
COMMIT;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'olist'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
