-- CASE 1: Revenue decline investigation
-- Compare first half vs second half of the year by region.
WITH region_period AS (
    SELECT
        c.region,
        CASE WHEN EXTRACT(MONTH FROM o.order_date) <= 6 THEN 'H1' ELSE 'H2' END AS period,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS revenue
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY c.region, period
)
SELECT
    region,
    ROUND(MAX(revenue) FILTER (WHERE period = 'H1'), 2) AS h1_revenue,
    ROUND(MAX(revenue) FILTER (WHERE period = 'H2'), 2) AS h2_revenue,
    ROUND(100 * (MAX(revenue) FILTER (WHERE period = 'H2') - MAX(revenue) FILTER (WHERE period = 'H1'))
        / NULLIF(MAX(revenue) FILTER (WHERE period = 'H1'), 0), 2) AS h2_vs_h1_pct
FROM region_period
GROUP BY region
ORDER BY h2_vs_h1_pct;

-- CASE 2: Customers whose latest month revenue fell by >20% vs previous active month
WITH customer_month AS (
    SELECT
        o.customer_id,
        DATE_TRUNC('month', o.order_date)::date AS month,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY 1, 2
), lagged AS (
    SELECT
        *,
        LAG(revenue) OVER (PARTITION BY customer_id ORDER BY month) AS previous_revenue
    FROM customer_month
)
SELECT
    customer_id,
    month,
    ROUND(revenue, 2) AS current_revenue,
    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND(100 * (revenue - previous_revenue) / NULLIF(previous_revenue, 0), 2) AS change_pct
FROM lagged
WHERE previous_revenue IS NOT NULL
  AND revenue < previous_revenue * 0.80
ORDER BY change_pct
LIMIT 50;

-- CASE 3: 80/20-style Pareto: cumulative share of revenue by customer
WITH customer_revenue AS (
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY 1
), ranked AS (
    SELECT
        *,
        SUM(revenue) OVER () AS total_revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue
    FROM customer_revenue
)
SELECT
    customer_id,
    ROUND(revenue, 2) AS revenue,
    ROUND(100 * cumulative_revenue / NULLIF(total_revenue, 0), 2) AS cumulative_revenue_pct
FROM ranked
WHERE cumulative_revenue / NULLIF(total_revenue, 0) <= 0.80
ORDER BY revenue DESC;

-- CASE 4: Campaign effectiveness: revenue, orders, AOV
SELECT
    COALESCE(ca.campaign_name, 'No Campaign') AS campaign,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)), 2) AS revenue,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct))
        / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS aov
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
LEFT JOIN campaigns ca ON ca.campaign_id = o.campaign_id
WHERE o.status = 'Delivered'
GROUP BY 1
ORDER BY revenue DESC;

-- CASE 5: Payment method performance
SELECT
    payment_method,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(order_revenue), 2) AS revenue,
    ROUND(AVG(order_revenue), 2) AS aov
FROM (
    SELECT
        o.order_id,
        o.payment_method,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS order_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY 1, 2
) x
GROUP BY payment_method
ORDER BY revenue DESC;
