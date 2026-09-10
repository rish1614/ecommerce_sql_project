# 8-Hour Execution Plan

## Hour 0–1: Environment + data model

1. Start PostgreSQL.
2. Generate the data.
3. Load all six tables.
4. Inspect row counts.
5. Draw the ER relationship on paper.

Checkpoint: explain the grain of every table in one sentence.

## Hour 1–2: Data quality + basic SQL

Run `03_quality_checks.sql`.
Then write your own versions of the checks using SELECT, WHERE, GROUP BY, HAVING, COUNT, CASE, and NULL handling.

Checkpoint: identify exactly which columns may contain missing data and which columns must never be missing.

## Hour 2–3: Revenue + KPI analysis

Run `04_kpis.sql` and reproduce the main metrics without looking at the solution.

Checkpoint: explain the difference between gross sales, net sales, refunds, net revenue, and AOV.

## Hour 3–4: Customer analysis

Run `05_customer_analysis.sql`.
Then modify the segmentation thresholds and build your own customer summary.

Checkpoint: explain one-time vs repeat customers and why counting rows after a JOIN can be misleading.

## Hour 4–5: Product + time analysis

Run `06_product_analysis.sql` and `07_time_analysis.sql`.
Practice top-N-per-category, monthly revenue, month-over-month growth, and cumulative revenue.

Checkpoint: explain exactly why `GROUP BY` alone cannot solve a top-3-within-each-category problem cleanly.

## Hour 5–6: Retention + churn + profitability

Run `08_retention_churn.sql` and `09_profitability.sql`.
Question the business assumptions behind each metric.

Checkpoint: explain why a churn definition is a business rule, not a universal SQL rule.

## Hour 6–7: Advanced business cases

Run `10_advanced_cases.sql`.
Then change the business question yourself, e.g. compare Q1 vs Q4, or calculate revenue decline by acquisition channel.

Checkpoint: for every query, be able to say what business decision the output supports.

## Hour 7–8: Final client report + interview preparation

Run `12_final_client_report.sql`.
Turn the results into 5 slides:

1. Executive summary
2. Revenue trend
3. Customer behavior
4. Product/category performance
5. Recommendations and next steps

Checkpoint: explain the whole analysis in 3 minutes without showing code.

## What makes this a >5 hour project

Do not simply run the scripts. For each analysis:

- Read the business question.
- Predict what the result should look like.
- Write the query yourself.
- Compare with the supplied solution.
- Explain the query line by line.
- Change at least one requirement.
- Validate the result with a second method.
- Write one business implication.

That turns a code-reading exercise into real analyst preparation.
