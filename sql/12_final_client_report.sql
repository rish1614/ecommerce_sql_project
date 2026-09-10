-- FINAL CLIENT REPORT
-- Run these queries after the earlier analysis scripts.

-- 1. Executive KPI block
WITH delivered AS (
    SELECT o.order_id, o.customer_id, o.order_date, o.shipping_cost,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS net_sales,
           SUM(oi.quantity * p.unit_cost) AS cogs,
           COALESCE(SUM(r.refund_amount), 0) AS refunds
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    LEFT JOIN returns r ON r.order_item_id = oi.order_item_id
    WHERE o.status = 'Delivered'
    GROUP BY o.order_id, o.customer_id, o.order_date, o.shipping_cost
)
SELECT
    COUNT(*) AS delivered_orders,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(net_sales - refunds), 2) AS net_revenue,
    ROUND(AVG(net_sales - refunds), 2) AS aov,
    ROUND(SUM(net_sales - refunds - cogs - shipping_cost), 2) AS contribution_profit
FROM delivered;

-- 2. Monthly trend + growth
WITH monthly AS (
    SELECT DATE_TRUNC('month', o.order_date)::date AS month,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS revenue
    FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY 1
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 2) AS mom_growth_pct
FROM monthly
ORDER BY month;

-- 3. Top categories
SELECT p.category,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)), 2) AS revenue
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY p.category
ORDER BY revenue DESC;

-- 4. Highest-value customers
SELECT c.customer_id, c.customer_name, c.region,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)), 2) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.customer_name, c.region
ORDER BY revenue DESC
LIMIT 20;

-- 5. Customer repeat rate
WITH customer_orders AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS orders
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS purchasing_customers,
    COUNT(*) FILTER (WHERE orders >= 2) AS repeat_customers,
    ROUND(100.0 * COUNT(*) FILTER (WHERE orders >= 2) / COUNT(*), 2) AS repeat_customer_pct
FROM customer_orders;

-- 6. Return reasons
SELECT reason, COUNT(*) AS return_events,
       SUM(return_qty) AS units_returned,
       ROUND(SUM(refund_amount), 2) AS refunds
FROM returns
GROUP BY reason
ORDER BY refunds DESC;

-- 7. Regional profitability
WITH order_profit AS (
    SELECT o.order_id, c.region, o.shipping_cost,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS sales,
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
SELECT region,
       ROUND(SUM(sales - refunds), 2) AS net_revenue,
       ROUND(SUM(sales - refunds - cogs - shipping_cost), 2) AS contribution_profit,
       ROUND(100.0 * SUM(sales - refunds - cogs - shipping_cost)
             / NULLIF(SUM(sales - refunds), 0), 2) AS margin_pct
FROM order_profit
GROUP BY region
ORDER BY contribution_profit DESC;

-- 8. Acquisition channel performance
SELECT COALESCE(c.acquisition_channel, 'Unknown') AS acquisition_channel,
       COUNT(DISTINCT c.customer_id) AS customers,
       COUNT(DISTINCT o.order_id) FILTER (WHERE o.status = 'Delivered') AS delivered_orders,
       ROUND(SUM(CASE WHEN o.status = 'Delivered'
                      THEN oi.quantity * oi.unit_price * (1 - oi.discount_pct) ELSE 0 END), 2) AS revenue
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY 1
ORDER BY revenue DESC;

-- 9. Top 3 products by category
WITH product_sales AS (
    SELECT p.category, p.product_id, p.product_name,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS revenue
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY 1,2,3
), ranked AS (
    SELECT *, DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk
    FROM product_sales
)
SELECT category, product_id, product_name, ROUND(revenue,2) AS revenue
FROM ranked
WHERE rnk <= 3
ORDER BY category, revenue DESC;

-- 10. Churn-risk customers using a 90-day inactivity definition.
WITH last_order AS (
    SELECT customer_id, MAX(order_date) AS last_order_date
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name, c.region, l.last_order_date,
       CURRENT_DATE - l.last_order_date AS inactive_days
FROM customers c
JOIN last_order l ON l.customer_id = c.customer_id
WHERE CURRENT_DATE - l.last_order_date > 90
ORDER BY inactive_days DESC;
