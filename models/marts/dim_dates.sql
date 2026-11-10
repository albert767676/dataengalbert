
{{ config(
    materialized='table',
    distributed_replicated=true
) }}

with date_bounds as (

    select
        min(order_date) as min_date,
        max(order_date) as max_date
    from {{ ref('stg_shop__orders') }}

),

calendar as (

    select
        generate_series(
            min_date,
            max_date,
            interval '1 day'
        )::date as date_day
    from date_bounds

)

select
    date_day,
    extract(year from date_day)::integer as year,
    extract(quarter from date_day)::integer as quarter,
    extract(month from date_day)::integer as month,
    extract(day from date_day)::integer as day_of_month,
    extract(isodow from date_day)::integer as day_of_week,
    case
        when extract(isodow from date_day) in (6, 7)
        then true
        else false
    end as is_weekend
from calendar
