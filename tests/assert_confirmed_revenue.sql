with successful_payments as (
    select
        order_id,
        count(*) as successful_count
    from {{ source('shop', 'payments') }}
    where payment_status = 'success'
      and amount > 0
    group by order_id
),

source_revenue as (
    select
        sum(o.total_amount) as revenue
    from {{ source('shop', 'orders') }} as o
    join successful_payments as p
        on o.order_id = p.order_id
    where o.status = 'paid'
      and o.order_id not in (
          select order_id
          from {{ ref('stg_shop__orders') }}
          where is_test_order
      )
),

mart_revenue as (
    select
        sum(order_amount) as revenue
    from {{ ref('fct_orders') }}
    where is_confirmed = true
)

select
    s.revenue as source_revenue,
    m.revenue as mart_revenue
from source_revenue as s
cross join mart_revenue as m
where coalesce(s.revenue, 0) <> coalesce(m.revenue, 0)
