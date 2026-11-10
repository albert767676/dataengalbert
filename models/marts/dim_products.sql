
{{ config(
    materialized='table',
    distributed_replicated=true
) }}

select
    {{ dbt_utils.generate_surrogate_key(['p.product_id']) }} as product_sk,
    p.product_id,
    p.product_name,
    p.brand,
    c.category_id,
    c.category_name,
    c.parent_category_name,
    c.root_category_name
from {{ ref('stg_shop__products') }} as p
left join {{ ref('int_product_categories') }} as c
    on p.category = c.category_name
