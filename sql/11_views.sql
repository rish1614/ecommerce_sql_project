-- Reusable analyst-friendly views.

CREATE OR REPLACE VIEW v_order_line_revenue AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    o.payment_method,
    o.shipping_cost,
    o.campaign_id,
    oi.order_item_id,
    oi.product_id,
    oi.quantity,
    oi.unit_price,
    oi.discount_pct,
    ROUND((oi.quantity * oi.unit_price)::numeric, 2) AS gross_line_sales,
    ROUND((oi.quantity * oi.unit_price * oi.discount_pct)::numeric, 2) AS discount_amount,
    ROUND((oi.quantity * oi.unit_price * (1 - oi.discount_pct))::numeric, 2) AS net_line_sales
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id;

CREATE OR REPLACE VIEW v_customer_order_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    c.region,
    c.acquisition_channel,
    COUNT(DISTINCT CASE WHEN o.status = 'Delivered' THEN o.order_id END) AS delivered_orders,
    MIN(CASE WHEN o.status = 'Delivered' THEN o.order_date END) AS first_order_date,
    MAX(CASE WHEN o.status = 'Delivered' THEN o.order_date END) AS last_order_date,
    COALESCE(SUM(CASE WHEN o.status = 'Delivered' THEN oi.quantity * oi.unit_price * (1 - oi.discount_pct) END), 0) AS gross_customer_revenue
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.customer_name, c.region, c.acquisition_channel;

CREATE OR REPLACE VIEW v_product_summary AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.brand,
    p.unit_cost,
    p.list_price,
    COALESCE(SUM(CASE WHEN o.status = 'Delivered' THEN oi.quantity END), 0) AS units_sold,
    COALESCE(SUM(CASE WHEN o.status = 'Delivered' THEN oi.quantity * oi.unit_price * (1 - oi.discount_pct) END), 0) AS net_sales
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
LEFT JOIN orders o ON o.order_id = oi.order_id
GROUP BY p.product_id, p.product_name, p.category, p.subcategory, p.brand, p.unit_cost, p.list_price;
