-- RFM-сегменты покупателей (21 304 пользователя с покупкой).
-- R — дней от последней покупки до 28.02.2021; F — заказы: покупки внутри одной
-- 30-минутной сессии считаются одним заказом; M — сумма price.
-- Баллы: F — 1 / 2 / 3+ заказа; R и M — терцили через percentile_disc и case,
-- чтобы одинаковые значения не попадали в разные баллы (как бывает у ntile).
-- Сегменты: best — лучшие, perspective — перспективные, need_return — нужно вернуть,
-- dormant — спящие, almost_lost — почти потерянные. Ветка 'не попал' — контроль
-- полноты правил, в результате её быть не должно.
-- Для Power BI выгружалась таблица покупателей:
--   select user_id, last_purcahse, recency_days, frequency, monetary, f, m, r, segment from e7

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
e4 as (
select 
	user_id, 
	max(event_time) last_purcahse,
	date '2021-02-28' - max(event_time)::date recency_days,
	count(distinct new_session) as frequency,
	sum(price) monetary
from e3
where event_type = 'purchase'
group by user_id
),
borders as (
	select
        percentile_disc(1/3.0) within group (order by monetary)     as m1,
        percentile_disc(2/3.0) within group (order by monetary)     as m2,
        percentile_disc(1/3.0) within group (order by recency_days) as r1,
        percentile_disc(2/3.0) within group (order by recency_days) as r2
    from e4
),
e5 as (
	select *
	from e4
	cross join borders
),
e6 as (
select user_id, last_purcahse, recency_days, frequency, monetary,
	case
		when frequency = 1 then 1
		when frequency = 2 then 2
		when frequency > 2 then 3
	end f,
	case
		when monetary <= m1 then 1
		when monetary <= m2 then 2
		else 3
	end m,
	case
		when recency_days <= r1 then 3
		when recency_days <= r2 then 2
		else 1
	end r
from e5
),
e7 as (
select *,
	case
		when (r = 3 and f >= 2 and m = 3) or (r = 3 and f = 3 and m = 2) then 'best'
		when (r = 3 and f = 1 and m <= 3) or (r = 3 and f = 2 and m <= 2) or (r = 3 and f = 3 and m = 1) then 'perspective'
		when (r = 2 and f >= 1 and m = 3) or (r = 2 and f >= 2 and m = 2) or (r = 1 and f >= 1 and m = 3) then 'need_return'
		when (r = 2 and f = 1 and m <= 2) or (r = 2 and f >= 2 and m = 1) then 'dormant'
		when (r = 1 and f = 1 and m <= 2) or (r = 1 and f = 2 and m <= 2) or (r = 1 and f = 3 and m <= 2) then 'almost_lost'
		else 'не попал'
	end segment
from e6
)
select 
	segment,
	count(*) cnt_buyers,
	round((count(*) / (select count(*) from e7)::numeric) * 100, 2) rate_cnt,
	sum(monetary) monetary, 
	round((sum(monetary) / (select sum(monetary) from e7)) * 100, 2) rate_monetary
from e7
group by segment
order by 2 desc
