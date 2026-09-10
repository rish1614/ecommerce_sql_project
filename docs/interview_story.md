# Interview Story

Use this structure when discussing the project.

## 1. Problem
I built an e-commerce analytics project to understand revenue, customer behavior, product performance, returns, and profitability from transactional data.

## 2. Data
The data model has customers, products, campaigns, orders, order items, and returns. The most important relationship is customers -> orders -> order_items -> products.

## 3. Approach
I started with data-quality checks, then created reusable order-line metrics. I used joins for relational analysis, CTEs for multi-step calculations, and window functions for ranking, month-over-month analysis, cumulative totals, and customer behavior.

## 4. Business questions
- What is net revenue and AOV?
- Which products/categories drive sales?
- Which customers are high value?
- How is revenue changing month over month?
- Which customers appear at risk?
- What is the return rate?
- Which regions/categories produce the strongest contribution profit?
- How does campaign attribution differ?

## 5. Recommendation style
Do not present a number alone. State the finding, driver, implication, recommendation, and next metric to monitor.
