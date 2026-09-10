# Interview Questions and Model Answers

## A. Data model and SQL fundamentals

### 1. What is the grain of `order_items`?

One row per product line within an order. An order can therefore contain multiple `order_items` rows.

### 2. Why can a join inflate the number of rows?

Because a one-to-many relationship produces multiple child rows for one parent row. If an order has four items, joining the order to the items produces four result rows for that order.

### 3. Why use `COUNT(DISTINCT order_id)`?

Because after joining to `order_items`, the same order may appear more than once.

### 4. `WHERE` vs `HAVING`?

`WHERE` filters rows before grouping. `HAVING` filters groups after aggregation.

### 5. `INNER JOIN` vs `LEFT JOIN`?

`INNER JOIN` keeps only matching records from both sides. `LEFT JOIN` keeps every row from the left table and adds matches where they exist.

### 6. Why use `COALESCE`?

To replace `NULL` with a defined fallback, such as zero refunds for an order with no return record.

### 7. Why use `NULLIF`?

To prevent division-by-zero errors, especially in ratios and percentage calculations.

## B. CTEs and window functions

### 8. Why use a CTE?

A CTE breaks a complex calculation into named logical stages. It improves readability, debugging, and reviewability.

### 9. GROUP BY vs window function?

GROUP BY collapses rows into groups. A window function calculates across related rows while retaining the individual rows in the result.

### 10. ROW_NUMBER vs RANK vs DENSE_RANK?

- `ROW_NUMBER` gives every row a unique sequential number.
- `RANK` gives tied rows the same rank and leaves gaps.
- `DENSE_RANK` gives tied rows the same rank without gaps.

### 11. Why use `PARTITION BY category`?

It restarts the ranking calculation separately within each category.

### 12. What does `LAG` do?

It returns a value from a previous row according to the specified ordering, such as previous-month revenue.

## C. Business metrics

### 13. How is net revenue defined in this project?

Gross sales minus discounts minus refunds, using delivered orders only.

### 14. How is AOV defined?

Net revenue divided by delivered orders.

### 15. Why should AOV use an order-level denominator?

Because AOV measures revenue per order, not per order line.

### 16. What is contribution profit?

Net revenue minus COGS minus shipping cost under the project's assumptions.

### 17. Why not report gross sales as the final revenue number?

Because discounts and refunds reduce the realized value of the sales.

## D. Customer analytics

### 18. How did you define repeat customers?

Customers with at least two delivered orders.

### 19. How did you define churn risk?

More than 90 days since the latest delivered order, using `2025-12-31` as the historical analysis end date.

### 20. Is 90 days universally correct?

No. It is a project assumption. A real churn threshold should reflect the normal purchase cycle.

### 21. What is RFM?

Recency, Frequency, Monetary value. It is a way to summarize customer engagement and value.

## E. Product and profitability analytics

### 22. Why can the highest-revenue category not be the best category?

Because revenue ignores cost, shipping, discounting, and returns. A lower-revenue category can generate higher profit or margin.

### 23. Why count shipping cost once per order?

Because it is modeled as an order-level cost. Repeating it for every order line would overstate cost.

### 24. What would you investigate for a high-return product?

Return reason, product category, seller/fulfillment context if available, discounting, customer expectations, and whether the return rate is high relative to comparable products.

## F. Campaign and experimentation

### 25. Does high campaign revenue prove high campaign ROI?

No. It is descriptive performance. Without an incremental baseline, control group, or strong attribution design, causal ROI cannot be established.

### 26. What would you do next for campaign measurement?

Design an experiment or holdout group, define the conversion window, measure incremental revenue or contribution profit, and account for campaign cost.

## G. Validation and client communication

### 27. How did you validate the analysis?

I independently calculated the same KPIs in SQL and Python and compared the results.

### 28. What if SQL and Python disagree?

I would check table grain, joins, filters, null handling, aggregation order, refund logic, date filtering, and the denominator used by ratios.

### 29. How do you communicate a result to a client?

State the finding, quantify its size, explain the likely driver, give the business implication, and recommend a measurable next step.

### 30. What is a good analyst recommendation?

One that is directly tied to evidence, feasible for the business, explicit about assumptions, and linked to a metric that can be monitored after implementation.
