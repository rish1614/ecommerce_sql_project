-- 1. Row counts
SELECT 'customers' AS table_name, COUNT(*) AS rows FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'campaigns', COUNT(*) FROM campaigns
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'returns', COUNT(*) FROM returns;

-- 2. Null checks on important dimensions
SELECT
    COUNT(*) FILTER (WHERE city IS NULL) AS missing_city,
    COUNT(*) FILTER (WHERE acquisition_channel IS NULL) AS missing_acquisition_channel
FROM customers;

-- 3. Duplicate primary keys
SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT order_item_id, COUNT(*)
FROM order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1;

-- 4. Orphan checks: should return zero rows.
SELECT o.order_id
FROM orders o
LEFT JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

SELECT oi.order_item_id
FROM order_items oi
LEFT JOIN products p ON p.product_id = oi.product_id
WHERE p.product_id IS NULL;

-- 5. Invalid quantities/prices/discounts
SELECT * FROM order_items
WHERE quantity <= 0
   OR unit_price < 0
   OR discount_pct < 0
   OR discount_pct > 1;

-- 6. Return quantities greater than purchased quantities
SELECT
    r.return_id,
    r.order_item_id,
    r.return_qty,
    oi.quantity
FROM returns r
JOIN order_items oi ON oi.order_item_id = r.order_item_id
WHERE r.return_qty > oi.quantity;

-- 7. Date sanity checks
SELECT MIN(order_date) AS min_order_date, MAX(order_date) AS max_order_date
FROM orders;

SELECT MIN(signup_date) AS min_signup_date, MAX(signup_date) AS max_signup_date
FROM customers;
