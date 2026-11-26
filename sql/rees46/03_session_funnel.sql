-- Воронка по сессиям: доля сессий с просмотром, корзиной и покупкой.
-- Два определения сессии: user_session сайта и 30-минутные сессии —
-- user_session, разрезанная на визиты по паузам больше 30 минут
-- (LAG даёт паузу, нарастающая сумма флагов — номер визита).
-- 165 событий без user_session не входят (покупок среди них нет).
-- Ожидаемо: user_session — 490 398 сессий, 99,58 / 8,42 / 4,96%;
--           new_session — 539 734 сессии, 99,42 / 8,08 / 4,77%.

with e1 as (
	select *,
		e.event_time - lag(e.event_time) over (partition by e.user_session order by e.event_time) as pause
	from rees46.events e
	where user_session is not null
),
e2 as(
	select *,
		case when pause is null or pause > interval '30 minutes' then 1 else 0 end as new_visit
	from e1
),
e3 as (
	select *,
		sum(new_visit) over (partition by user_session order by event_time) as visit_no,
		user_session || '-' || (sum(new_visit) over (partition by user_session order by event_time)) as new_session
	from e2
),
s_site as (
	select user_session as session_key,
           bool_or(event_type = 'view') as has_view,
           bool_or(event_type = 'cart') as has_cart,
           bool_or(event_type = 'purchase') as has_purchase
    from e3
    group by user_session
),
s_new as (
	select new_session as session_key,
           bool_or(event_type = 'view') as has_view,
           bool_or(event_type = 'cart') as has_cart,
           bool_or(event_type = 'purchase') as has_purchase
    from e3
    group by new_session
)
select 
	'user_session' as method, 
	count(*) as sessions,
	avg(has_view::int) * 100 as rate_view,
	avg(has_cart::int) * 100 as rate_cart,
	avg(has_purchase::int) * 100 as rate_purchase
from s_site
union all
select 
	'new_session' as method, 
	count(*) as sessions,
	avg(has_view::int) * 100 as rate_view,
	avg(has_cart::int) * 100 as rate_cart,
	avg(has_purchase::int) * 100 as rate_purchase
from s_new
