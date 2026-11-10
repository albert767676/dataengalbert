select
    o.order_id,
    o.order_amount,
    coalesce(sum(i.line_amount), 0) as items_amount
from {{ ref('fct_orders') }} as o
left join {{ ref('fct_order_items') }} as i
    on o.order_id = i.order_id
group by
    o.order_id,
    o.order_amount
having o.order_amount <> coalesce(sum(i.line_amount), 0)
