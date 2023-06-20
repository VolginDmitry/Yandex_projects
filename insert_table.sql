INSERT INTO public.shipping_country_rates
(shipping_country, shipping_country_base_rate)
select distinct on (shipping_country, shipping_country_base_rate) shipping_country, shipping_country_base_rate
from public.shipping;


INSERT INTO public.shipping_agreement
(agreement_id, agreement_number, agreement_rate, agreement_commission)
select 	distinct on (category[1]::BIGINT) category[1]::BIGINT as agreement_id,
		category[2]::TEXT as agreement_number,
		category[3]::NUMERIC(14,3) as agreement_rate,
		category[4]::NUMERIC(14,3) as agreement_commission
from (	select regexp_split_to_array(vendor_agreement_description,  E'\\:+') as category
		from public.shipping) as shipping_agreement;


INSERT INTO public.shipping_transfer
(transfer_type, transfer_model, shipping_transfer_rate)
select 	distinct on (category[2], category[1], shipping_transfer_rate)
		category[1]::TEXT as transfer_type,
		category[2]::TEXT as transfer_model,
		shipping_transfer_rate::NUMERIC(14,3) as shipping_transfer_rate
from (	select 	regexp_split_to_array(shipping_transfer_description,  E'\\:+') as category,
	  			shipping_transfer_rate 
		from public.shipping) as shipping_transfer;


IINSERT INTO public.shipping_info
(shipping_id,vendor_id,payment_amount,shipping_plan_datetime,shipping_transfer_id,shipping_agreement_id,shipping_country_rate_id)

select 	distinct on (shipping_id)
		shipping_id::BIGINT,
		vendor_id::BIGINT,
		payment_amount::NUMERIC(14,2),
		shipping_plan_datetime::TIMESTAMP,
		st.id::BIGINT as shipping_transfer_id,
		sa.agreement_id::BIGINT as shipping_agreement_id,
		scr.id::BIGINT as shipping_country_rate_id
from (	select *, (regexp_split_to_array(vendor_agreement_description,  E'\\:+'))[1]::BIGINT as agreement_id
  		from public.shipping) as s
left join shipping_transfer as st on (regexp_split_to_array(s.shipping_transfer_description , E'\:+'))[1] = st.transfer_type
                                  and (regexp_split_to_array(s.shipping_transfer_description , E'\:+'))[2] = st.transfer_model
left join public.shipping_agreement as sa using(agreement_id)
left join public.shipping_country_rates as scr using(shipping_country) 
order by shipping_id, shipping_transfer_id;


INSERT INTO public.shipping_status 
(shipping_id,status,state,shipping_start_fact_datetime,shipping_end_fact_datetime)
with st as (select shipping_id, state_datetime as shipping_start_fact_datetime
			from public.shipping
			where state = 'booked'),
	 fn as (select 	distinct on(shipping_id) 
					shipping_id, 
					status, 
					state,
					state_datetime as shipping_end 
			from public.shipping
			order by shipping_id, state_datetime desc)
select  shipping_id, 
		status, 
		state,
		shipping_start_fact_datetime,
		case 
			when state in ('recieved','returned') then shipping_end 
			else null 
		end as shipping_end_fact_datetime
from fn 
inner join st as s using(shipping_id);
