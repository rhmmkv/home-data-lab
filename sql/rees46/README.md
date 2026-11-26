# SQL анализа REES46 Electronics

Запросы для PostgreSQL, схема `rees46`, одна таблица `events` — одна строка на событие. Аналитические запросы читают исходную таблицу; промежуточные таблицы не создаются, все шаги — CTE.

| Файл | Назначение |
|---|---|
| [01_create_tables.sql](01_create_tables.sql) | Схема `rees46`, таблица `events`, права чтения для `analyst` |
| [02_verify_import.sql](02_verify_import.sql) | Сверка 11 показателей с исходным CSV: строки, типы событий, пользователи, выручка, границы времени, пропуски |
| [03_session_funnel.sql](03_session_funnel.sql) | Воронка по сессиям для двух определений сессии (вопрос 1) |
| [04_retention_cohorts.sql](04_retention_cohorts.sql) | Недельные когорты и retention (вопрос 2) |
| [05_rfm_segments.sql](05_rfm_segments.sql) | RFM-баллы и сегменты покупателей (вопрос 3) |

Загрузка CSV — [scripts/import_rees46.sh](../../scripts/import_rees46.sh): создаёт таблицу (SQL 01), выполняет `COPY` и сверку (SQL 02).

Используемые приёмы: оконные функции `LAG`, нарастающая `sum() over`, `max() over`, `percentile_disc`, `bool_or`, `date_trunc`, `cross join` со строкой границ.

[Отчёт](../../analysis/rees46/REPORT.md) · [Порядок воспроизведения](../../docs/reproduce.md#7-повторить-анализ-rees46-версия-03)
