-- Product performance
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)), 2) AS net_sales
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY net_sales DESC
LIMIT 20;

-- Top 3 products within each category
WITH product_sales AS (
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS net_sales
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY 1, 2, 3
), ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY category
               ORDER BY net_sales DESC
           ) AS rn
    FROM product_sales
)
SELECT category, product_id, product_name, ROUND(net_sales, 2) AS net_sales
FROM ranked
WHERE rn <= 3
ORDER BY category, net_sales DESC;

-- Category sales and contribution
WITH category_sales AS (
    SELECT
        p.category,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS sales
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY p.category
), total AS (
    SELECT SUM(sales) AS total_sales FROM category_sales
)
SELECT
    c.category,
    ROUND(c.sales, 2) AS sales,
    ROUND(100 * c.sales / NULLIF(t.total_sales, 0), 2) AS sales_share_pct
FROM category_sales c
CROSS JOIN total t
ORDER BY sales DESC;

-- Product gross margin estimate
SELECT
    p.category,
    ROUND(SUM(oi.quantity * (oi.unit_price * (1 - oi.discount_pct) - p.unit_cost)), 2) AS gross_profit,
    ROUND(100 * SUM(oi.quantity * (oi.unit_price * (1 - oi.discount_pct) - p.unit_cost))
        / NULLIF(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)), 0), 2) AS gross_margin_pct
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY p.category
ORDER BY gross_profit DESC;
