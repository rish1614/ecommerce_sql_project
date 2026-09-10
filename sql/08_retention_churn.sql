-- Monthly customer activity matrix
WITH customer_months AS (
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', order_date)::date AS month
    FROM orders
    WHERE status = 'Delivered'
), first_purchase AS (
    SELECT customer_id, MIN(month) AS first_month
    FROM customer_months
    GROUP BY customer_id
)
SELECT
    cm.month,
    COUNT(DISTINCT cm.customer_id) AS active_customers,
    COUNT(DISTINCT CASE WHEN cm.month = fp.first_month THEN cm.customer_id END) AS new_customers,
    COUNT(DISTINCT CASE WHEN cm.month > fp.first_month THEN cm.customer_id END) AS returning_customers
FROM customer_months cm
JOIN first_purchase fp ON fp.customer_id = cm.customer_id
GROUP BY cm.month
ORDER BY cm.month;

-- Simple churn definition:
-- A customer is considered churn-risk if their most recent delivered order is more than 90 days before 2025-12-31.
WITH last_purchase AS (
    SELECT customer_id, MAX(order_date) AS last_order_date
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN last_order_date < DATE '2025-10-03' THEN 'Churn Risk'
        WHEN last_order_date < DATE '2025-11-03' THEN 'At Risk'
        ELSE 'Active'
    END AS lifecycle_status,
    COUNT(*) AS customers
FROM last_purchase
GROUP BY 1
ORDER BY 1;

-- Cohort retention by signup month (purchase activity after signup)
WITH first_purchase AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date))::date AS cohort_month
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY customer_id
), activity AS (
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', order_date)::date AS activity_month
    FROM orders
    WHERE status = 'Delivered'
), cohorts AS (
    SELECT
        fp.cohort_month,
        a.activity_month,
        COUNT(DISTINCT a.customer_id) AS active_customers
    FROM first_purchase fp
    JOIN activity a ON a.customer_id = fp.customer_id
    GROUP BY 1, 2
)
SELECT
    cohort_month,
    activity_month,
    active_customers,
    (EXTRACT(YEAR FROM age(activity_month, cohort_month)) * 12
      + EXTRACT(MONTH FROM age(activity_month, cohort_month)))::int AS months_since_first_purchase
FROM cohorts
ORDER BY cohort_month, activity_month;
