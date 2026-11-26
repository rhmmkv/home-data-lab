-- Home Data Lab v0.3.0: таблица для исходного events.csv REES46 Electronics.
-- Запускать в home_data_lab ролью lab_admin, psql с ON_ERROR_STOP=1.
-- Создаёт пустую таблицу; загрузка — scripts/import_rees46.sh.

BEGIN;

CREATE SCHEMA rees46 AUTHORIZATION lab_admin;

-- Одна строка = одно событие (view, cart или purchase) одного пользователя с одним товаром.
-- event_time в CSV имеет вид '2020-09-24 11:57:06 UTC'. Хранится как
-- timestamp without time zone со временем UTC (суффикс для этого типа PostgreSQL
-- игнорирует). Так дни совпадают с Power BI, а клиенты вроде DBeaver не сдвигают
-- значения в свой часовой пояс.
-- Идентификаторы — text: это метки, а не количества (как в схеме olist).
-- Пустые поля CSV (brand, category_code, user_session) становятся NULL.
CREATE TABLE rees46.events (
    event_time timestamp without time zone,  -- UTC
    event_type text,
    product_id text,
    category_id text,
    category_code text,
    brand text,
    price numeric,
    user_id text,
    user_session text
);

GRANT USAGE ON SCHEMA rees46 TO analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA rees46 TO analyst;

COMMIT;
