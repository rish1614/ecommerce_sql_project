-- Product-level contribution profit
WITH delivered_items AS (
    SELECT
        o.order_id,
        o.shipping_cost,
        oi.order_item_id,
        oi.quantity,
        oi.product_id,
        oi.unit_price,
        oi.discount_pct,
        p.unit_cost,
        oi.quantity * oi.unit_price * (1 - oi.discount_pct) AS net_sales,
        oi.quantity * p.unit_cost AS cogs
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    WHERE o.status = 'Delivered'
), order_shipping AS (
    SELECT order_id, shipping_cost FROM orders WHERE status = 'Delivered'
), returns_by_item AS (
    SELECT order_item_id, SUM(refund_amount) AS refund
    FROM returns
    GROUP BY order_item_id
)
SELECT
    di.product_id,
    p.product_name,
    p.category,
    ROUND(SUM(di.net_sales - COALESCE(r.refund, 0) - di.cogs), 2) AS product_gross_profit
FROM delivered_items di
JOIN products p ON p.product_id = di.product_id
LEFT JOIN returns_by_item r ON r.order_item_id = di.order_item_id
GROUP BY di.product_id, p.product_name, p.category
ORDER BY product_gross_profit DESC
LIMIT 20;

-- Contribution margin by region, including shipping cost
WITH order_profit AS (
    SELECT
        o.order_id,
        c.region,
        o.shipping_cost,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS net_sales,
        SUM(oi.quantity * p.unit_cost) AS cogs,
        COALESCE(SUM(r.refund_amount), 0) AS refunds
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    LEFT JOIN returns r ON r.order_item_id = oi.order_item_id
    WHERE o.status = 'Delivered'
    GROUP BY o.order_id, c.region, o.shipping_cost
)
SELECT
    region,
    ROUND(SUM(net_sales - refunds), 2) AS net_revenue,
    ROUND(SUM(cogs), 2) AS cogs,
    ROUND(SUM(shipping_cost), 2) AS shipping_cost,
    ROUND(SUM(net_sales - refunds - cogs - shipping_cost), 2) AS contribution_profit,
    ROUND(100 * SUM(net_sales - refunds - cogs - shipping_cost)
        / NULLIF(SUM(net_sales - refunds), 0), 2) AS contribution_margin_pct
FROM order_profit
GROUP BY region
ORDER BY contribution_profit DESC;

-- Return analysis
SELECT
    r.reason,
    COUNT(*) AS return_events,
    SUM(r.return_qty) AS units_returned,
    ROUND(SUM(r.refund_amount), 2) AS refund_amount
FROM returns r
GROUP BY r.reason
ORDER BY refund_amount DESC;

-- Product return rate by units
WITH sold AS (
    SELECT
        oi.product_id,
        SUM(oi.quantity) AS units_sold
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY oi.product_id
), returned AS (
    SELECT oi.product_id, SUM(r.return_qty) AS units_returned
    FROM returns r
    JOIN order_items oi ON oi.order_item_id = r.order_item_id
    GROUP BY oi.product_id
)
SELECT
    p.product_id,
    p.product_name,
    s.units_sold,
    COALESCE(rt.units_returned, 0) AS units_returned,
    ROUND(100.0 * COALESCE(rt.units_returned, 0) / NULLIF(s.units_sold, 0), 2) AS return_rate_pct
FROM sold s
JOIN products p ON p.product_id = s.product_id
LEFT JOIN returned rt ON rt.product_id = s.product_id
ORDER BY return_rate_pct DESC
LIMIT 20;
