

WITH WHALES as (
    select
        output_address,
        sum(output_value) as total_sent,
        count(*) as tx_count

    from {{ ref('stg_btc_transactions')}}

    where output_value > 10

    group by output_address
    order by total_sent desc
)

{# now used macro to get the price
LATEST_PRICE as (
	select
	    price
	from {{ ref('btc_usd_max')}}
	where to_date(replace(snapped_at,' UTC','')) = current_date()
) #}

select
    w.output_address,
    w.total_sent,
    w.tx_count,
    {# (p.price * w.total_sent) as total_sent_usd #}
    {{ convert_to_usd('w.total_sent')}} as total_sent_usd
from WHALES w
{# cross join LATEST_PRICE p #}