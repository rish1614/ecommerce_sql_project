# Methodology and Metric Definitions

## 1. Analytical objective

The project evaluates an e-commerce business across five dimensions:

1. Revenue performance.
2. Customer behavior and retention.
3. Product/category performance.
4. Returns and operational impact.
5. Contribution profitability.

The analysis deliberately moves from raw transactional tables to order-level business metrics so that calculations respect table grain.

## 2. Core analytical principle: calculate at the correct grain

`order_items` is line-level. Therefore a single order can appear multiple times after joining `orders` to `order_items`.

The standard pattern is:

```text
order_items
    ↓
calculate line-level sales
    ↓
aggregate to order level
    ↓
calculate order-level KPIs
    ↓
aggregate to customer / product / region / month as needed
```

This prevents row multiplication from distorting order counts, shipping costs, refunds, or AOV.

## 3. Revenue definitions

### Gross sales

```text
Gross Sales = quantity × unit_price
```

### Discount amount

```text
Discount = quantity × unit_price × discount_pct
```

### Net sales before returns

```text
Net Sales Before Returns = Gross Sales − Discount
```

### Refunds

```text
Refunds = SUM(refund_amount)
```

### Net revenue

```text
Net Revenue = Net Sales Before Returns − Refunds
```

Only orders with:

```text
status = 'Delivered'
```

are included in realized-sales analysis.

## 4. Average Order Value

```text
AOV = Net Revenue / Delivered Orders
```

AOV should be calculated using order-level net revenue and a delivered-order denominator.

## 5. Cost definitions

### COGS

```text
COGS = quantity × unit_cost
```

### Contribution profit

```text
Contribution Profit = Net Revenue − COGS − Shipping Cost
```

### Contribution margin

```text
Contribution Margin % = Contribution Profit / Net Revenue × 100
```

Shipping cost is treated as an order-level cost and should be counted once per order.

## 6. Customer metrics

### Purchasing customer

A customer with at least one delivered order during the analysis period.

### Repeat customer

A customer with at least two delivered orders.

### One-time customer

A customer with exactly one delivered order.

### RFM-style analysis

The project uses:

- **Recency**: days since the latest delivered order.
- **Frequency**: number of delivered orders.
- **Monetary**: delivered-order revenue.

The current implementation is a descriptive RFM-style summary rather than a universal scoring standard.

## 7. Churn methodology

The project uses inactivity as a proxy for churn risk.

A customer is treated as churn-risk when the latest delivered order is more than 90 days before the analysis end date.

For the 2025 dataset, the correct historical anchor is:

```sql
DATE '2025-12-31'
```

Do not use `CURRENT_DATE` in a historical report because the output would change as time passes.

### Churn limitation

The 90-day threshold is an analytical assumption. A production churn model should be calibrated to normal purchase frequency and business context.

## 8. Monthly trend methodology

Monthly revenue is aggregated by:

```sql
DATE_TRUNC('month', order_date)
```

Month-over-month growth is calculated as:

```text
(Current Month Revenue − Previous Month Revenue)
/ Previous Month Revenue × 100
```

The previous month is obtained using:

```sql
LAG(revenue) OVER (ORDER BY month)
```

## 9. Product analysis

Products are evaluated by:

- units sold;
- net sales;
- category contribution;
- gross profit;
- gross margin;
- return rate.

Top-N analysis uses window functions such as `ROW_NUMBER()` or `DENSE_RANK()` partitioned by category.

## 10. Return analysis

Returns are analyzed using:

- return-event count;
- units returned;
- refund amount;
- product-level return rate.

A simple unit return-rate definition is:

```text
Return Rate % = Units Returned / Units Sold × 100
```

## 11. Campaign analysis

Campaign analysis is descriptive:

- delivered orders;
- revenue;
- AOV;
- campaign attribution.

High campaign revenue does not prove incremental campaign impact or ROI because the project does not contain randomized control groups or a complete attribution model.

## 12. Pareto / concentration analysis

Customer revenue is sorted from highest to lowest. A cumulative revenue share is calculated with a running window sum.

The objective is to answer:

> What proportion of customers contributes to approximately 80% of revenue?

This is a concentration diagnostic, not a requirement that the business follow a literal 80/20 law.

## 13. SQL vs Python validation

The same core KPIs are independently calculated through:

```text
PostgreSQL SQL
        vs
Python / pandas
```

The shared validation metrics are:

- delivered orders;
- purchasing customers;
- net revenue;
- AOV.

Contribution profit and contribution margin are also cross-checked using an order-level cost calculation.

Agreement after sensible rounding provides evidence that the analytical logic is internally consistent across two implementations.

## 14. Rounding

Currency metrics are reported to two decimal places. Tiny floating-point representation differences should not be treated as business discrepancies when the rounded values agree.

## 15. Assumption policy

The following are analytical assumptions for this synthetic project and should be confirmed with a real client's Finance or Analytics team:

- what constitutes realized revenue;
- whether refunds are recognized in the same period as sales;
- whether shipping belongs in contribution profit;
- the churn threshold;
- the customer-segmentation thresholds;
- treatment of campaign attribution.
