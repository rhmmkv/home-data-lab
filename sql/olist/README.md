# SQL анализа Olist

Запросы предназначены для PostgreSQL. Единица анализа — заказ. Все аналитические запросы читают исходные таблицы схемы `olist`; постоянные промежуточные таблицы не создаются.

| Файл | Назначение |
|---|---|
| [01_create_tables.sql](01_create_tables.sql) | Создание пустой схемы, девяти таблиц и прав чтения |
| [02_verify_counts.sql](02_verify_counts.sql) | Сверка количества строк с CSV |
| [04_orders_initial_checks.sql](04_orders_initial_checks.sql) | Уникальность заказов и пропуски ключевых полей |
| [05_orders_monthly_counts.sql](05_orders_monthly_counts.sql) | Границы периода, месячные количества и сверка суммы |
| [06_orders_daily_tail.sql](06_orders_daily_tail.sql) | Дневной ряд за август–октябрь 2018 года |
| [07_orders_monthly_statuses.sql](07_orders_monthly_statuses.sql) | Состав статусов по месяцам оформления |
| [08_delivery_dates_by_status.sql](08_delivery_dates_by_status.sql) | Наличие фактической даты по статусам |
| [09_delivery_lateness_rate.sql](09_delivery_lateness_rate.sql) | Доля опоздавших среди доставленных заказов с обеими датами |
| [10_delivery_lateness_median.sql](10_delivery_lateness_median.sql) | Медианная задержка среди опоздавших |
| [11_latest_order_reviews.sql](11_latest_order_reviews.sql) | Выбор последнего отзыва и проверка уникальности |
| [12_delivery_reviews_join_checks.sql](12_delivery_reviews_join_checks.sql) | Проверка соединения заказов с отзывами |
| [13_delivery_reviews_comparison.sql](13_delivery_reviews_comparison.sql) | Сравнение средних оценок и долей оценок 1–2 |
| [14_dashboard_kpis.sql](14_dashboard_kpis.sql) | Три отдельных запроса карточек Metabase |
| [15_dashboard_reviews.sql](15_dashboard_reviews.sql) | Сравнение оценок для графика и таблицы Metabase |

Для основных результатов выполнить SQL 09–13. Для дашборда — SQL 14–15. В файлах с несколькими запросами выполнять каждый запрос отдельно в SQL-клиенте; файл целиком также можно передать `psql`.

В исходном наборе предполагаемая дата имеет время `00:00`. Выбор последнего отзыва через максимум времени требует проверки, что на заказ выбрана одна строка; она включена в SQL 11.

[Ожидаемые результаты и порядок запуска](../../docs/reproduce.md) · [Отчёт](../../analysis/olist/REPORT.md)
