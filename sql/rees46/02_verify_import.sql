-- Проверка загрузки, только чтение. Ожидаемые значения посчитаны по исходному
-- events.csv (data/sources.json и отдельный пересчёт CSV).
-- event_time хранит UTC как timestamp without time zone.

WITH checks (check_name, actual, expected) AS (
    SELECT 'rows', count(*)::text, '885129' FROM rees46.events
    UNION ALL
    SELECT 'view', count(*) FILTER (WHERE event_type = 'view')::text, '793748'
    FROM rees46.events
    UNION ALL
    SELECT 'cart', count(*) FILTER (WHERE event_type = 'cart')::text, '54035'
    FROM rees46.events
    UNION ALL
    SELECT 'purchase', count(*) FILTER (WHERE event_type = 'purchase')::text, '37346'
    FROM rees46.events
    UNION ALL
    SELECT 'distinct users', count(DISTINCT user_id)::text, '407283'
    FROM rees46.events
    UNION ALL
    SELECT 'purchase revenue', sum(price) FILTER (WHERE event_type = 'purchase')::text,
           '5125395.62'
    FROM rees46.events
    UNION ALL
    SELECT 'first event UTC',
           to_char(min(event_time), 'YYYY-MM-DD HH24:MI:SS'),
           '2020-09-24 11:57:06'
    FROM rees46.events
    UNION ALL
    SELECT 'last event UTC',
           to_char(max(event_time), 'YYYY-MM-DD HH24:MI:SS'),
           '2021-02-28 23:59:09'
    FROM rees46.events
    UNION ALL
    SELECT 'null category_code', count(*) FILTER (WHERE category_code IS NULL)::text,
           '236219'
    FROM rees46.events
    UNION ALL
    SELECT 'null brand', count(*) FILTER (WHERE brand IS NULL)::text, '212364'
    FROM rees46.events
    UNION ALL
    SELECT 'null user_session', count(*) FILTER (WHERE user_session IS NULL)::text,
           '165'
    FROM rees46.events
)
SELECT check_name, actual, expected, actual = expected AS matches
FROM checks;
