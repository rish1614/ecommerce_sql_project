# Dashboard Guide

## 1. Dashboard objective

The dashboard should convert the SQL/Python analysis into a management-friendly interface. It should answer:

> What is happening, where is value being created or lost, and what should management investigate next?

## 2. Page 1 — Executive Overview

### KPI cards

- Net Revenue
- Delivered Orders
- Purchasing Customers
- AOV
- Contribution Profit
- Contribution Margin %

### Visuals

1. Monthly net revenue line chart.
2. Monthly orders and AOV trend.
3. Revenue versus contribution profit summary.

### Interpretation

The first page should surface the Q4 uplift and make the overall economics visible without requiring the user to inspect raw tables.

## 3. Page 2 — Customer

### KPIs

- Purchasing customers
- Repeat-customer rate
- One-time customers
- Average customer revenue

### Visuals

- New versus returning customers by month.
- Customer segment distribution.
- Top customers by revenue.
- Pareto cumulative-revenue curve.

### Business question

Are we relying primarily on first-time buyers, or is repeat purchasing strong enough to support sustainable growth?

## 4. Page 3 — Products

### KPIs

- Units sold
- Net revenue
- Gross profit
- Gross margin
- Return rate

### Visuals

- Revenue by category.
- Gross margin by category.
- Top products.
- High-return products.

### Business question

Which products should receive more attention based on value rather than sales alone?

## 5. Page 4 — Marketing

### KPIs

- Campaign-attributed orders
- Campaign revenue
- Campaign AOV
- Acquisition-channel revenue

### Visuals

- Revenue by acquisition channel.
- Campaign revenue ranking.
- Campaign AOV.

### Business caution

Label campaign results as descriptive attribution, not causal ROI.

## 6. Page 5 — Profitability and Returns

### KPIs

- Contribution profit
- Contribution margin
- Refunds
- Units returned

### Visuals

- Contribution profit by region.
- Contribution margin by region.
- Refund value by return reason.
- Product return-rate ranking.

### Business question

Where is revenue turning into actual economic value, and where is value being lost through cost or returns?

## 7. Recommended filters

Keep global filters limited to those that answer common management questions:

- Month / date.
- Region.
- Category.
- Acquisition channel.
- Payment method.
- Campaign.

Do not create dozens of low-value slicers.

## 8. Dashboard design principle

Each page should have:

```text
KPI
  ↓
Trend / comparison
  ↓
Breakdown
  ↓
Business action
```

Avoid charts that show data without supporting a decision.
