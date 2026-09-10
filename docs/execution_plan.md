# Reproducible Execution Plan

## 1. Purpose

This document gives the exact workflow for recreating the analysis from the project root.

## 2. Prerequisites

- Ubuntu/Linux environment.
- Python 3.x.
- Python virtual environment.
- Docker Engine.
- Docker Compose plugin.
- Git.

## 3. Activate the environment

```bash
cd ~/Projects/ecommerce_sql_project
source .venv/bin/activate
```

Verify:

```bash
which python
python --version
```

## 4. Start PostgreSQL

```bash
docker compose up -d
```

Verify:

```bash
docker ps
```

The project database service is PostgreSQL, exposed on the configured local port.

## 5. Generate the dataset

```bash
python data_generator/generate_data.py
```

The generator should create:

```text
data/customers.csv
data/products.csv
data/campaigns.csv
data/orders.csv
data/order_items.csv
data/returns.csv
```

## 6. Load PostgreSQL

```bash
python python/load_postgres.py
```

Expected completion message:

```text
Schema created and CSVs loaded successfully.
```

## 7. Verify tables

```bash
docker exec -it ecommerce-postgres psql -U analyst -d ecommerce_analytics
```

Inside `psql`:

```sql
\dt
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM returns;
SELECT COUNT(*) FROM campaigns;
\q
```

## 8. Run the data-quality checks

```bash
./run_sql.sh sql/03_quality_checks.sql
```

Do not move forward until you understand every non-zero result.

## 9. Run the analytical SQL files

```bash
./run_sql.sh sql/04_kpis.sql
./run_sql.sh sql/05_customer_analysis.sql
./run_sql.sh sql/06_product_analysis.sql
./run_sql.sh sql/07_time_analysis.sql
./run_sql.sh sql/08_retention_churn.sql
./run_sql.sh sql/09_profitability.sql
./run_sql.sh sql/10_advanced_cases.sql
./run_sql.sh sql/11_views.sql
./run_sql.sh sql/12_final_client_report.sql
```

If validation files exist:

```bash
./run_sql.sh sql/13_validation.sql
./run_sql.sh sql/14_profit_validation.sql
```

## 10. Run Python analysis

```bash
python python/analyze_results.py
```

Then run the notebook:

```bash
jupyter notebook
```

Open:

```text
notebooks/ecommerce_analysis.ipynb
```

Select the project kernel and run all cells from top to bottom.

## 11. Validate SQL against Python

The shared validation metrics are:

```text
delivered orders
purchasing customers
net revenue
AOV
```

Compare SQL results with the Python KPI output.

Contribution profit and contribution margin should also be checked using order-level calculations.

## 12. Historical-report rule

Because the dataset ends on `2025-12-31`, historical churn/inactivity calculations should use that date as the analysis end date.

Avoid:

```sql
CURRENT_DATE
```

for historical churn in the final report.

Prefer:

```sql
DATE '2025-12-31'
```

## 13. Git workflow

Check:

```bash
git status
```

Stage:

```bash
git add .
```

Commit with a specific message:

```bash
git commit -m "Document analytics methodology and findings"
```

Push:

```bash
git push origin main
```

## 14. Reproducibility test

For a final project check:

```text
Start Docker
    ↓
Generate data
    ↓
Load PostgreSQL
    ↓
Run data-quality checks
    ↓
Run all SQL analyses
    ↓
Run Python analysis
    ↓
Run notebook
    ↓
Validate SQL vs Python
    ↓
Review findings
```

The complete workflow should execute from a clean environment without manual editing of intermediate results.

## 15. Operational note

Use:

```bash
docker compose down
```

when stopping the project temporarily.

Avoid:

```bash
docker compose down -v
```

unless you intentionally want to remove the PostgreSQL Docker volume and recreate the database from scratch.
