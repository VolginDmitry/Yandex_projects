drop table if exists public.shipping_country_rates;
drop table if exists public.shipping_agreement;
drop table if exists public.shipping_transfer;
drop table if exists public.shipping_info;
drop table if exists public.shipping_status;


CREATE TABLE public.shipping_country_rates(
   id           					   serial,
   shipping_country      			text,
   shipping_country_base_rate    NUMERIC(14,3),
   PRIMARY KEY (id)
);

CREATE TABLE public.shipping_agreement (
   agreement_id           	BIGINT,
   agreement_number      	TEXT,
   agreement_rate       	NUMERIC(14,2),
   agreement_commission		NUMERIC(14,2),
   PRIMARY KEY (agreement_id)
);

CREATE TABLE public.shipping_transfer (
   id           			   serial,
   transfer_type      		TEXT,
   transfer_model       	TEXT,
   shipping_transfer_rate	NUMERIC(14,3),
   PRIMARY KEY (id)
);

CREATE TABLE public.shipping_info (
   shipping_id           		BIGINT,
   vendor_id      				BIGINT,
   payment_amount             NUMERIC(14,2),
   shipping_plan_datetime     TIMESTAMP,
   shipping_transfer_id  		BIGINT,
   shipping_agreement_id  		BIGINT,
   shipping_country_rate_id  	BIGINT,
   FOREIGN KEY  (shipping_transfer_id) REFERENCES public.shipping_transfer(id) ON UPDATE cascade,
   FOREIGN KEY  (shipping_agreement_id) REFERENCES public.shipping_agreement(agreement_id) ON UPDATE cascade,
   FOREIGN KEY  (shipping_country_rate_id) REFERENCES public.shipping_country_rates(id) ON UPDATE cascade
);

CREATE TABLE public.shipping_status  (
   shipping_id           				BIGINT,
   status               				TEXT,
   state               					TEXT,
   shipping_start_fact_datetime     TIMESTAMP,
   shipping_end_fact_datetime       TIMESTAMP,
   PRIMARY KEY (shipping_id)
);
