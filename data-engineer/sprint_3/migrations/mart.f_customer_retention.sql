delete
from mart.f_customer_retention
where period_id=(select week_of_year from mart.d_calendar dc where '{{ds}}' = dc.date_actual);

insert into mart.f_customer_retention (period_name,period_id,item_id,new_customers_count,returning_customers_count,refunded_customer_count,new_customers_revenue,returning_customers_revenue,customers_refunded)
with 
new_clients as
	(select customer_id
	from mart.f_sales
	where status = 'shipped'
	group by customer_id
	having count(*) = 1),
returning_clients as
	(select customer_id
	from mart.f_sales
	where status = 'shipped'
	group by customer_id
	having count(*) > 1),
refunded_clients as
	(select customer_id
	from mart.f_sales
	where status = 'refunded'
	group by customer_id)
select 	'weekly' as period_name,
		week_of_year as period_id,
		item_id,
		count(distinct customer_id) filter(where customer_id in (select customer_id from new_clients)) as new_customers_count,
		count(distinct customer_id) filter(where customer_id in (select customer_id from returning_clients)) as returning_customers_count,
		count(distinct customer_id) filter(where customer_id in (select customer_id from refunded_clients)) as refunded_customer_count,
		sum(payment_amount) filter(where customer_id in (select customer_id from new_clients)) as new_customers_revenue,
		sum(payment_amount) filter(where customer_id in (select customer_id from returning_clients)) as returning_customers_revenue,
		coalesce(sum(quantity) filter(where customer_id in (select customer_id from refunded_clients)), 0) as customers_refunded
from mart.f_sales
left join mart.d_calendar as dc using(date_id)
where date_actual::Date = '{{ds}}'
group by week_of_year,item_id;



