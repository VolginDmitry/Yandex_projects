CREATE VIEW shipping_datamart  AS
select 	si.shipping_id,
		vendor_id,
		transfer_type,
		extract('day' from age(shipping_end_fact_datetime,shipping_start_fact_datetime)):: BIGINT as full_day_at_shipping,
		case
			when shipping_end_fact_datetime > shipping_plan_datetime then 1
			else 0
		end as is_delay,
		case
			when status = 'finished' then 1
			else 0
		end as is_shipping_finish,
		case
			when shipping_end_fact_datetime > shipping_plan_datetime then extract('day' from age(shipping_end_fact_datetime,shipping_plan_datetime)):: BIGINT
			else 0
		end as delay_day_at_shipping,
		payment_amount,
		payment_amount *(shipping_country_base_rate + agreement_rate + shipping_transfer_rate) as vat,
		payment_amount * agreement_commission as profit 
from public.shipping_info as si
join shipping_transfer as st on st.id = si.shipping_transfer_id
join shipping_status  as ss using(shipping_id)
join shipping_agreement as sa on sa.agreement_id = si.shipping_agreement_id
join shipping_country_rates as scr on scr.id = si.shipping_country_rate_id
order by shipping_id
