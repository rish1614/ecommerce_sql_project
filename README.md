# E-commerce Business Analytics — SQL Project

This project is designed as a 7–9 hour analyst interview preparation project. It deliberately combines SQL syntax, relational reasoning, business metrics, data-quality checks, and client-style recommendations.

## Learning objectives

By the end you should be comfortable with:

- SELECT / WHERE / GROUP BY / HAVING
- CASE and NULL handling
- INNER / LEFT joins
- subqueries and CTEs
- date functions
- window functions: ROW_NUMBER, RANK, LAG, LEAD, running totals
- customer/product/revenue analysis
- cohort and churn-style analysis
- profitability and return analysis
- explaining SQL results as business recommendations

## Project structure

```
data_generator/   -> reproducible data generation
 data/             -> CSV data
sql/               -> schema, load, checks, analysis, views
python/            -> optional validation/visualization
 docs/              -> data dictionary + interview story
```

## Step 1: Generate the data

From the project root:

```bash
python data_generator/generate_data.py
```

This generates six CSV files.

## Step 2: Create PostgreSQL database

Using a local PostgreSQL installation:

```bash
createdb ecommerce_analytics
psql -d ecommerce_analytics -f sql/01_schema.sql
psql -d ecommerce_analytics -f sql/02_load.sql
```

If your working directory is not the project root, update the paths in `sql/02_load.sql` to absolute paths.

## Step 3: Validate data

```bash
psql -d ecommerce_analytics -f sql/03_quality_checks.sql
```

Do not move on until you can explain why every check exists and what a non-zero result would mean.

## Step 4: Core analysis

Run, in order:

```text
04_kpis.sql
05_customer_analysis.sql
06_product_analysis.sql
07_time_analysis.sql
08_retention_churn.sql
09_profitability.sql
10_advanced_cases.sql
11_views.sql
```

## Step 5: Optional Python analysis

Install requirements:

```bash
pip install -r requirements.txt
```

Then:

```bash
python python/analyze_results.py
```

This gives you a few sanity-check outputs and charts.

## Step 6: Interview preparation

Be able to explain:

1. The grain of each table.
2. Why joins can multiply rows.
3. Why revenue is calculated only on delivered orders.
4. How refunds are separated from pre-return sales.
5. Why a CTE helps readability.
6. Why a window function is different from GROUP BY.
7. How LAG produces month-over-month comparisons.
8. How you defined churn and its limitations.
9. How you would validate the final numbers before giving them to a client.

## Important metric definitions

**Gross sales** = quantity × unit price

**Discount** = quantity × unit price × discount_pct

**Net sales before returns** = gross sales − discount

**Refunds** = sum of returned-item refund amounts

**Net revenue** = net sales before returns − refunds

**Contribution profit** = net revenue − COGS − shipping cost

**AOV** = net revenue / delivered orders

These definitions are analytical assumptions for this synthetic project. In a real client project, confirm the finance team's metric definitions before reporting results.
