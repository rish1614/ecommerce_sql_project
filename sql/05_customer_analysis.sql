-- Customer revenue summary
WITH customer_revenue AS (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS delivered_orders,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS revenue_before_returns
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY o.customer_id
), customer_refunds AS (
    SELECT o.customer_id, SUM(r.refund_amount) AS refunds
    FROM returns r
    JOIN orders o ON o.order_id = r.order_id
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    c.region,
    c.acquisition_channel,
    cr.delivered_orders,
    ROUND(cr.revenue_before_returns - COALESCE(cf.refunds, 0), 2) AS net_revenue
FROM customer_revenue cr
JOIN customers c ON c.customer_id = cr.customer_id
LEFT JOIN customer_refunds cf ON cf.customer_id = cr.customer_id
ORDER BY net_revenue DESC
LIMIT 20;

-- Customer segmentation using CASE
WITH customer_revenue AS (
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) - COALESCE(SUM(r.refund_amount), 0) AS net_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    LEFT JOIN returns r ON r.order_item_id = oi.order_item_id
    WHERE o.status = 'Delivered'
    GROUP BY o.customer_id
)
SELECT
    CASE
        WHEN net_revenue >= 50000 THEN 'VIP'
        WHEN net_revenue >= 20000 THEN 'High Value'
        WHEN net_revenue >= 5000 THEN 'Mid Value'
        ELSE 'Low Value'
    END AS segment,
    COUNT(*) AS customers,
    ROUND(AVG(net_revenue), 2) AS avg_revenue,
    ROUND(SUM(net_revenue), 2) AS total_revenue
FROM customer_revenue
GROUP BY 1
ORDER BY total_revenue DESC;

-- Repeat vs one-time customers
WITH orders_per_customer AS (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    CASE WHEN order_count = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type,
    COUNT(*) AS customers
FROM orders_per_customer
GROUP BY 1;

-- Customers with no delivered orders
SELECT c.customer_id, c.customer_name
FROM customers c
LEFT JOIN orders o
    ON o.customer_id = c.customer_id
   AND o.status = 'Delivered'
WHERE o.order_id IS NULL;

-- RFM-style summary (simple version)
WITH last_purchase AS (
    SELECT customer_id, MAX(order_date) AS last_order_date
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY customer_id
), frequency AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS frequency
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY customer_id
), monetary AS (
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS monetary
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    CURRENT_DATE - lp.last_order_date AS recency_days,
    f.frequency,
    ROUND(m.monetary, 2) AS monetary_value
FROM customers c
JOIN last_purchase lp ON lp.customer_id = c.customer_id
JOIN frequency f ON f.customer_id = c.customer_id
JOIN monetary m ON m.customer_id = c.customer_id
ORDER BY monetary_value DESC
LIMIT 50;
