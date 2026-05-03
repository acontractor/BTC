{{ 
    config(
        materialized = 'incremental',
        incremental_strategy = 'append'
    ) 
}}

with flattened_outputs as (
    select
        sb.hash_key,
        sb.block_number,
        sb.block_timestamp,
        sb.is_coinbase,
        f.value:address::STRING as output_address,
        f.value:value::FLOAT as output_value

    from {{ ref('stg_btc')}} sb,

    LATERAL FLATTEN(input => outputs) f

    WHERE f.value:address is not null

    {% if is_incremental() %}
        AND sb.block_timestamp >= (
            SELECT max(sb.block_timestamp)
            FROM {{ this }}
        )
    {% endif %}
)

select
    hash_key,
    block_number,
    block_timestamp,
    is_coinbase,
    output_address,
    output_value
from flattened_outputs 