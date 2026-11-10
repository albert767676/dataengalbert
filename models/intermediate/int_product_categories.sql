
{{ config(materialized='view') }}

with recursive category_tree as (

    select
        category_id,
        parent_category_id,
        category_name,
        cast(null as text) as parent_category_name,
        category_name as root_category_name,
        1 as category_level
    from {{ ref('stg_shop__product_categories') }}
    where parent_category_id is null

    union all

    select
        child.category_id,
        child.parent_category_id,
        child.category_name,
        parent.category_name as parent_category_name,
        parent.root_category_name,
        parent.category_level + 1
    from {{ ref('stg_shop__product_categories') }} as child
    join category_tree as parent
        on child.parent_category_id = parent.category_id

)

select
    category_id,
    parent_category_id,
    category_name,
    parent_category_name,
    root_category_name,
    category_level
from category_tree
