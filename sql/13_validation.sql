WITH item_sales AS (
    SELECT
        o.order_id,
        o.customer_id,
        oi.quantity,
        oi.unit_price,
        oi.discount_pct,
        oi.quantity * oi.unit_price AS gross_sales,
        oi.quantity * oi.unit_price * oi.discount_pct AS discount_amount,
        oi.quantity * oi.unit_price * (1 - oi.discount_pct) AS net_sales
    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
),
refund_by_order AS (
    SELECT
        order_id,
        SUM(refund_amount) AS refunds
    FROM returns
    GROUP BY order_id
),
order_level AS (
    SELECT
        i.order_id,
        i.customer_id,
        SUM(i.gross_sales) AS gross_sales,
        SUM(i.discount_amount) AS discounts,
        SUM(i.net_sales) AS net_sales,
        COALESCE(r.refunds, 0) AS refunds
    FROM item_sales i
    LEFT JOIN refund_by_order r
        ON r.order_id = i.order_id
    GROUP BY
        i.order_id,
        i.customer_id,
        r.refunds
)
SELECT
    COUNT(*) AS delivered_orders,
    COUNT(DISTINCT customer_id) AS purchasing_customers,
    ROUND(SUM(net_sales - refunds), 2) AS net_revenue,
    ROUND(AVG(net_sales - refunds), 2) AS aov
FROM order_level;
