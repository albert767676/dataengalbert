
{{ config(materialized='view') }}

select
    product_id,
    product_name,
    brand,
    category
from {{ source('shop', 'products') }}
