# Analysis Guide

This document explains what each SQL analysis is trying to answer and what a good analyst should look for in the result.

## 1. SQL workflow

Run in this order:

```text
03_quality_checks.sql
04_kpis.sql
05_customer_analysis.sql
06_product_analysis.sql
07_time_analysis.sql
08_retention_churn.sql
09_profitability.sql
10_advanced_cases.sql
11_views.sql
12_final_client_report.sql
```

## 2. `03_quality_checks.sql` — Can the data be trusted?

Questions:

- Are row counts plausible?
- Are key identifiers duplicated?
- Do foreign keys resolve?
- Are dates within the expected analysis period?
- Are return quantities valid?
- Where is missing data?

Business interpretation:

Quality checks are evidence that the subsequent analysis is based on structurally consistent data.

## 3. `04_kpis.sql` — What is the overall business performance?

Primary outputs:

- delivered orders;
- purchasing customers;
- gross sales;
- discounts;
- refunds;
- net revenue;
- AOV.

Verified result from the current dataset:

| KPI | Value |
|---|---:|
| Delivered orders | 70,437 |
| Purchasing customers | 16,595 |
| Gross sales | 4,047,389,652.39 |
| Discounts | 337,195,367.89 |
| Refunds | 142,640,262.36 |
| Net revenue | 3,567,554,022.14 |
| AOV | 50,648.86 |

Interpretation:

The dataset contains a large realized-sales base, with discounts and refunds representing meaningful deductions from gross sales.

## 4. `05_customer_analysis.sql` — Who drives customer value?

Questions:

- Which customers have the highest realized revenue?
- How many delivered orders does each customer place?
- What share of customers are repeat buyers?
- Which customers appear valuable under RFM-style measures?
- How much revenue is concentrated among the highest-value customers?

Analytical warning:

Customer segmentation thresholds in the SQL are project-defined rules, not universal standards.

## 5. `06_product_analysis.sql` — What products and categories matter?

Questions:

- Which products generate the most net sales?
- Which three products lead within each category?
- What is each category's share of sales?
- Which categories produce the strongest gross profit and margin?

Key interview concept:

Revenue ranking and profit ranking can produce different leaders.

## 6. `07_time_analysis.sql` — When does the business perform best?

Questions:

- What is monthly revenue?
- What is month-over-month growth?
- What is cumulative revenue?
- How do orders and AOV change by month?
- Which days of the week have higher activity?

Key SQL concepts:

```text
DATE_TRUNC
LAG
SUM(...) OVER (...)
```

The existing monthly revenue output shows strong Q4 performance:

| Month | Net revenue |
|---|---:|
| Jan | 300,693,127.56 |
| Feb | 247,183,821.04 |
| Mar | 270,875,286.57 |
| Apr | 258,665,327.37 |
| May | 297,030,669.54 |
| Jun | 259,262,380.08 |
| Jul | 296,273,882.69 |
| Aug | 270,587,912.88 |
| Sep | 266,580,393.52 |
| Oct | 369,526,538.78 |
| Nov | 356,501,340.20 |
| Dec | 374,373,341.92 |

## 7. `08_retention_churn.sql` — Do customers come back?

Questions:

- How many active customers are there each month?
- How many are new versus returning?
- Which customers are inactive enough to be considered churn-risk?
- How do cohorts behave over time?

Key interview concept:

A churn threshold is a business assumption and should reflect normal buying frequency.

## 8. `09_profitability.sql` — Where is value actually created?

Questions:

- Which products generate the most gross profit?
- Which regions generate the most contribution profit?
- What are the largest return reasons?
- Which products have high return rates?

Key warning:

Profitability is more informative than revenue alone, but the result depends on the assumed `unit_cost` and shipping-cost fields in this synthetic dataset.

## 9. `10_advanced_cases.sql` — Can the analyst investigate a business problem?

The file covers:

1. H1 vs H2 regional revenue.
2. Customers with large month-over-month revenue declines.
3. Customer revenue concentration / Pareto analysis.
4. Campaign performance.
5. Payment-method performance.

These are closer to real interview questions because they start with a business problem rather than a SQL feature.

## 10. `11_views.sql` — Can analysis be reused?

Reusable views:

```text
v_order_line_revenue
v_customer_order_summary
v_product_summary
```

The purpose is to avoid repeatedly rebuilding common joins and calculations.

## 11. `12_final_client_report.sql` — Can the analysis be communicated?

The final report combines:

- executive KPIs;
- monthly trends;
- category performance;
- highest-value customers;
- repeat-customer rate;
- return reasons;
- regional profitability;
- acquisition channels;
- top products by category;
- churn-risk customers.

The final output should be turned into a concise management story rather than presented as a list of SQL queries.

## 12. Recommended interpretation framework

For every major result, answer five questions:

```text
1. What happened?
2. How large is the effect?
3. What appears to drive it?
4. What business implication follows?
5. What should we monitor or test next?
```

Avoid causal language unless the analysis actually supports causality.
