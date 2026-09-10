-- KPI definitions used throughout the project:
-- Gross Sales = SUM(quantity * unit_price)
-- Discount = SUM(quantity * unit_price * discount_pct)
-- Net Sales before returns = Gross Sales - Discount
-- Refunds = SUM(refund_amount)
-- Net Revenue = Net Sales before returns - Refunds
-- Product Gross Profit = Net item revenue - product cost of units sold
-- Contribution Profit = Product Gross Profit - shipping_cost
-- Realized revenue uses Delivered orders only.

WITH item_sales AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        oi.product_id,
        oi.quantity,
        oi.unit_price,
        oi.discount_pct,
        (oi.quantity * oi.unit_price) AS gross_sales,
        (oi.quantity * oi.unit_price * oi.discount_pct) AS discount_amount,
        (oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS net_line_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
), refund_by_order AS (
    SELECT order_id, SUM(refund_amount) AS refund_amount
    FROM returns
    GROUP BY order_id
), order_level AS (
    SELECT
        i.order_id,
        i.customer_id,
        i.order_date,
        SUM(i.gross_sales) AS gross_sales,
        SUM(i.discount_amount) AS discount_amount,
        SUM(i.net_line_revenue) AS net_sales_before_returns,
        COALESCE(r.refund_amount, 0) AS refund_amount
    FROM item_sales i
    LEFT JOIN refund_by_order r ON r.order_id = i.order_id
    GROUP BY i.order_id, i.customer_id, i.order_date, r.refund_amount
), final AS (
    SELECT *, net_sales_before_returns - refund_amount AS net_revenue
    FROM order_level
)
SELECT
    COUNT(*) AS delivered_orders,
    COUNT(DISTINCT customer_id) AS purchasing_customers,
    ROUND(SUM(gross_sales), 2) AS gross_sales,
    ROUND(SUM(discount_amount), 2) AS discounts,
    ROUND(SUM(refund_amount), 2) AS refunds,
    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(SUM(net_revenue) / NULLIF(COUNT(*), 0), 2) AS average_order_value,
    ROUND(AVG(net_revenue), 2) AS average_revenue_per_order
FROM final;

-- Revenue by month
WITH order_revenue AS (
    SELECT
        o.order_id,
        DATE_TRUNC('month', o.order_date)::date AS month,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS net_sales
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY 1, 2
), refunds AS (
    SELECT order_id, SUM(refund_amount) AS refund_amount
    FROM returns GROUP BY order_id
)
SELECT
    month,
    ROUND(SUM(net_sales - COALESCE(refund_amount, 0)), 2) AS net_revenue
FROM order_revenue r
LEFT JOIN refunds f USING (order_id)
GROUP BY month
ORDER BY month;
