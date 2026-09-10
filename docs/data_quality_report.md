# Data Quality Report

## 1. Purpose

Data-quality checks are performed before business analysis so that downstream KPIs are based on known and defensible data relationships.

The SQL implementation is in:

```text
sql/03_quality_checks.sql
```

## 2. Verified row counts

| Table | Verified rows | Status |
|---|---:|---|
| `customers` | 20,000 | PASS |
| `products` | 500 | PASS |
| `campaigns` | 8 | PASS |
| `orders` | 80,000 | PASS |
| `order_items` | 163,710 | PASS |
| `returns` | 6,479 | PASS |

## 3. Uniqueness checks

The project checks for duplicate primary-style keys in:

- `customers.customer_id`
- `orders.order_id`
- `order_items.order_item_id`

All duplicate checks returned zero rows.

Interpretation: each of these identifiers behaves as a unique key in the generated dataset.

## 4. Referential integrity checks

The project checks that foreign-key-style references resolve correctly:

```text
orders.customer_id -> customers.customer_id
order_items.order_id -> orders.order_id
order_items.product_id -> products.product_id
returns.order_id -> orders.order_id
returns.order_item_id -> order_items.order_item_id
```

All checks returned zero invalid references.

Interpretation: the main relational paths are internally consistent.

## 5. Missing values

The verified missing values in the customer table are:

| Column | Missing rows |
|---|---:|
| `city` | 376 |
| `acquisition_channel` | 296 |

These are attributes rather than transaction keys, so the records are retained for analysis.

## 6. Date range validation

### Orders

```text
Minimum order date: 2025-01-01
Maximum order date: 2025-12-31
```

### Customers

```text
Minimum signup date: 2023-01-12
Maximum signup date: 2025-01-01
```

## 7. Return validation

The data-quality checks confirm that return quantities do not exceed the associated sold quantity for the returned order items.

The return-generation process also samples returns only from delivered order items.

## 8. Data-quality conclusion

The current dataset passes the structural integrity checks required for the planned analysis. The only notable missingness is in non-key customer attributes (`city` and `acquisition_channel`).

## 9. Recommended client-facing wording

> The dataset passed key uniqueness and referential-integrity checks. A small amount of missing customer attribute data remains in city and acquisition-channel fields, but it does not affect the core transaction and revenue analysis. These records were retained rather than dropped.

## 10. Limitations

This report validates the internal consistency of the synthetic dataset. It does not prove that the generated values represent a real company's accounting, customer behavior, or operational processes.
