-- Недельные когорты и retention.
-- Когорта — календарная неделя (понедельник) первого события пользователя в данных.
-- «Вернулся» — любое событие в неделю week_no после недели когорты.
-- retention = пользователи когорты, активные в неделю week_no / размер когорты (week_no = 0), %.
-- Ожидаемо: 23 когорты, 276 строк; сумма cnt при week_no = 0 — 407 283.
-- Результат выгружен в CSV для матрицы Power BI.

with r1 as(
	select user_id, date_trunc('week', min(event_time)) as week_start
	from rees46.events e
	group by e.user_id
),
r2 as (
	select distinct user_id, date_trunc('week', event_time) as week_act
	from rees46.events e 
),
r3 as (
	select r1.user_id,
		week_start,
		(week_act::date - week_start::date) / 7 as week_no
	from r1 
	left join r2 on r1.user_id = r2.user_id
),
r4 as (
	select week_start, week_no, count(distinct user_id) as cnt
	from r3
	group by week_start, week_no
)
select week_start, week_no, cnt,
       cnt::numeric / max(cnt) over (partition by week_start) * 100 as retention
from r4
order by week_start, week_no
