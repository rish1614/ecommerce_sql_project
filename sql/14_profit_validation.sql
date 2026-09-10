WITH delivered_items AS (
    SELECT
        o.order_id,
        o.shipping_cost,
        oi.order_item_id,
        oi.quantity,
        oi.unit_price,
        oi.discount_pct,
        p.unit_cost,

        oi.quantity * oi.unit_price * (1 - oi.discount_pct)
            AS net_sales,

        oi.quantity * p.unit_cost
            AS cogs

    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.order_id
    JOIN products p
        ON p.product_id = oi.product_id

    WHERE o.status = 'Delivered'
),
refunds_by_item AS (
    SELECT
        order_item_id,
        SUM(refund_amount) AS refund
    FROM returns
    GROUP BY order_item_id
),
order_level AS (
    SELECT
        d.order_id,
        d.shipping_cost,
        SUM(d.net_sales) AS net_sales,
        SUM(d.cogs) AS cogs,
        COALESCE(SUM(r.refund), 0) AS refunds
    FROM delivered_items d
    LEFT JOIN refunds_by_item r
        ON r.order_item_id = d.order_item_id
    GROUP BY
        d.order_id,
        d.shipping_cost
)
SELECT
    ROUND(
        SUM(net_sales - refunds - cogs - shipping_cost),
        2
    ) AS contribution_profit,

    ROUND(
        100.0 *
        SUM(net_sales - refunds - cogs - shipping_cost)
        / NULLIF(SUM(net_sales - refunds), 0),
        2
    ) AS contribution_margin_pct
FROM order_level;
