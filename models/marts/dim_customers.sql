
{{ config(
    materialized='table',
    distributed_replicated=true
) }}

with confirmed_orders as (

    select
        order_id,
        customer_id,
        ordered_at,
        order_amount
    from {{ ref('fct_orders') }}
    where is_confirmed = true

),

ranked_orders as (

    select
        order_id,
        customer_id,
        ordered_at,
        row_number() over (
            partition by customer_id
            order by ordered_at, order_id
        ) as rn
    from confirmed_orders

),

first_orders as (

    select
        customer_id,
        order_id as first_confirmed_order_id,
        ordered_at as first_confirmed_at
    from ranked_orders
    where rn = 1

),

customer_stats as (

    select
        customer_id,
        count(*) as confirmed_orders_count,
        sum(order_amount) as confirmed_revenue
    from confirmed_orders
    group by customer_id

)

select
    c.customer_id,
    c.registered_at,
    c.registration_date,
    c.city,
    c.acquisition_channel,
    f.first_confirmed_order_id,
    f.first_confirmed_at,
    coalesce(s.confirmed_orders_count, 0) as confirmed_orders_count,
    coalesce(s.confirmed_revenue, 0) as confirmed_revenue,
    case
        when coalesce(s.confirmed_orders_count, 0) > 0
        then true
        else false
    end as is_buyer

from {{ ref('stg_shop__customers') }} as c

left join first_orders as f
    on c.customer_id = f.customer_id

left join customer_stats as s
    on c.customer_id = s.customer_id
