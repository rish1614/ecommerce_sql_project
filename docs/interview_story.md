# Interview Story

## 1. One-minute project explanation

> I built a synthetic e-commerce analytics project using PostgreSQL, SQL, Python, pandas, and Docker. The goal was to analyze revenue, customer behavior, product performance, returns, and contribution profitability. I started with data-quality and relational-integrity checks, then built order-line and order-level calculations, followed by customer, product, time-series, retention, return, and profitability analyses. I also implemented window-function based analyses such as rankings, month-over-month comparisons, running totals, and Pareto concentration. Finally, I independently reproduced the core KPIs in Python to validate the SQL calculations and prepared a client-style summary of findings and recommendations.

## 2. What problem were you solving?

The business problem is to understand:

- how much realized revenue the business generated;
- how revenue changes over time;
- which customers drive value;
- which products and categories drive sales and profit;
- where returns reduce realized value;
- which regions are most profitable;
- whether customer retention needs attention;
- and what management should do next.

## 3. Describe the data model

The core path is:

```text
customers -> orders -> order_items -> products
```

Campaigns connect to orders through `campaign_id`, while returns connect to orders and order items.

The most important grain issue is that `order_items` has multiple rows per order. Therefore order-level metrics require aggregation or `COUNT(DISTINCT order_id)`.

## 4. Why PostgreSQL?

PostgreSQL is the analytical database used for the project because the dataset is relational and the project needs joins, CTEs, date operations, conditional logic, aggregation, and window functions.

## 5. Why Docker?

Docker makes the database environment reproducible. A recruiter or teammate can start the same PostgreSQL service without manually installing and configuring a local database.

## 6. Explain the revenue methodology

The project defines:

```text
Gross sales = quantity × unit_price
Discounts = gross sales × discount_pct
Net sales before returns = gross sales − discounts
Net revenue = net sales before returns − refunds
```

Only delivered orders are included in realized-sales analysis.

## 7. Why use an order-level intermediate dataset?

Because an order can contain several line items. If shipping cost or refunds are aggregated naively after the join, the same order-level amount can be repeated for every item.

The solution is:

```text
line-level calculations
        ↓
aggregate to order level
        ↓
order-level KPI
```

## 8. Which SQL features did you use?

### Aggregation

`SUM`, `COUNT`, `AVG`, `MIN`, `MAX`

### Conditional logic

`CASE`, `FILTER`, `COALESCE`, `NULLIF`

### Joins

`INNER JOIN`, `LEFT JOIN`

### CTEs

Used to break multi-step business calculations into readable stages.

### Date functions

`DATE_TRUNC`, `EXTRACT`, `AGE`

### Window functions

`ROW_NUMBER`, `DENSE_RANK`, `LAG`, running `SUM`

## 9. Difference between GROUP BY and window functions

`GROUP BY` collapses multiple rows into fewer rows.

A window function calculates over a related set of rows while preserving the row-level result.

Example:

```sql
ROW_NUMBER() OVER (
    PARTITION BY category
    ORDER BY revenue DESC
)
```

allows top-N products within each category without collapsing the product rows before ranking.

## 10. Why use LAG?

`LAG` accesses a previous row in an ordered result. It is useful for month-over-month comparisons.

```sql
LAG(revenue) OVER (ORDER BY month)
```

provides previous-month revenue so growth can be calculated.

## 11. What were the verified high-level results?

The current validated KPI output is:

```text
Delivered orders:       70,437
Purchasing customers:   16,595
Gross sales:            4,047,389,652.39
Discounts:                337,195,367.89
Refunds:                  142,640,262.36
Net revenue:            3,567,554,022.14
AOV:                         50,648.86
```

The monthly output shows a strong Q4 uplift, with December the highest month in the verified series.

## 12. What is a limitation of your campaign analysis?

It is descriptive, not causal. A campaign being associated with high revenue does not prove the campaign created incremental sales.

To estimate causal impact, I would want randomized experiments, holdout groups, or a stronger attribution framework.

## 13. How did you validate the numbers?

I calculated the same core KPIs independently in PostgreSQL and Python.

```text
CSV
 ├──> PostgreSQL SQL
 └──> Python/pandas
          ↓
       compare
```

Agreement on delivered orders, purchasing customers, net revenue, and AOV provides an independent implementation check.

## 14. How did you define churn?

The project uses more than 90 days since the latest delivered order as a churn-risk proxy, anchored to `2025-12-31` for the historical dataset.

It is a project assumption, not a universal churn definition.

## 15. How would you explain a recommendation?

Use this structure:

```text
Finding
  ↓
Likely driver
  ↓
Business implication
  ↓
Recommendation
  ↓
Metric to monitor
```

Example:

> A category has high sales but weak contribution margin. That suggests volume is not translating efficiently into profit. I would investigate discount depth, product cost, shipping, and return rates before expanding promotional spend. I would monitor contribution margin and return rate after the change.

## 16. Strong interview questions to practice

- What is the grain of each table?
- Why do joins sometimes multiply rows?
- Why is `COUNT(DISTINCT order_id)` necessary?
- Why use `LEFT JOIN` for some analyses?
- What does `COALESCE` do?
- What does `NULLIF` protect against?
- Why use a CTE?
- What is the difference between `ROW_NUMBER` and `DENSE_RANK`?
- What does `LAG` return?
- How would you validate a dashboard number?
- How would you define churn for a real client?
- Why is descriptive campaign performance not the same as ROI?
- Why can revenue ranking disagree with profit ranking?

## 17. Interview closing statement

> The main thing I learned from the project was that analytical correctness depends as much on data grain and metric definitions as on SQL syntax. I therefore treated the workflow as a full analyst process: validate the data, define the metric, calculate it at the correct grain, cross-check the result independently, and only then convert the result into a business recommendation.
