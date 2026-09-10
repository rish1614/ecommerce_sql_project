# Data Dictionary and Data Model

## 1. Project dataset

This project uses a synthetic e-commerce transaction dataset created by `data_generator/generate_data.py`. The generator creates six CSV files covering customers, products, campaigns, orders, order items, and returns.

The current generated dataset contains:

| Table | Rows | Grain |
|---|---:|---|
| `customers` | 20,000 | One row per customer |
| `products` | 500 | One row per product |
| `campaigns` | 8 | One row per campaign |
| `orders` | 80,000 | One row per order |
| `order_items` | 163,710 | One row per product line within an order |
| `returns` | 6,479 | One row per return event for a returned order item |

These row counts were verified during the project data-quality checks.

## 2. Relationship model

The core transactional path is:

```text
customers
    |
    | customer_id
    | 1-to-many
    v
orders
    |
    | order_id
    | 1-to-many
    v
order_items
    |
    | product_id
    | many-to-1
    v
products
```

Additional relationships:

```text
orders.campaign_id  ->  campaigns.campaign_id
returns.order_id    ->  orders.order_id
returns.order_item_id -> order_items.order_item_id
```

## 3. Grain is critical

The project contains multiple grains:

- `customers`: customer grain.
- `orders`: order grain.
- `order_items`: order-line grain.
- `products`: product grain.
- `campaigns`: campaign grain.
- `returns`: return-event / returned-line grain.

Do not calculate order-level metrics directly after joining an order to order lines unless the aggregation logic accounts for row multiplication.

Example:

```sql
SELECT COUNT(*)
FROM orders o
JOIN order_items oi
    ON oi.order_id = o.order_id;
```

This counts order-item rows, not distinct orders.

For an order count after an order-item join, use:

```sql
COUNT(DISTINCT o.order_id)
```

## 4. `customers`

| Column | Type / role | Meaning | Notes |
|---|---|---|---|
| `customer_id` | Integer key | Unique customer key | Primary identifier |
| `customer_name` | Text | Customer display name | Synthetic name |
| `signup_date` | Date | Customer registration date | Used for customer lifecycle context |
| `gender` | Text | Gender category | Synthetic categorical field |
| `age` | Integer | Customer age | Generated between 18 and 70 |
| `city` | Text | Customer city | Small amount of missing data |
| `state` | Text | Customer state | Used with region mapping |
| `region` | Text | North / South / East / West | Derived during generation |
| `acquisition_channel` | Text | Initial acquisition channel | Small amount of missing data |

## 5. `products`

| Column | Type / role | Meaning | Notes |
|---|---|---|---|
| `product_id` | Integer key | Unique product key | Primary identifier |
| `product_name` | Text | Product label | Synthetic product name |
| `category` | Text | Main product category | Electronics, Home, Fashion, Beauty, Sports |
| `subcategory` | Text | Product subcategory | Category-specific |
| `brand` | Text | Brand label | Synthetic brand |
| `unit_cost` | Numeric | Estimated unit cost to the business | Used for gross/contribution profitability |
| `list_price` | Numeric | Listed selling price | Source price used in order generation |

## 6. `campaigns`

| Column | Type / role | Meaning | Notes |
|---|---|---|---|
| `campaign_id` | Integer key | Campaign identifier | Optional relationship from orders |
| `campaign_name` | Text | Campaign label | Synthetic campaign |
| `channel` | Text | Campaign marketing channel | Email / Social / Paid Search in the generated data |
| `start_date` | Date | Campaign start | Date range |
| `end_date` | Date | Campaign end | Date range |
| `budget` | Numeric | Campaign budget | Available for descriptive analysis; not sufficient by itself for causal ROI |

## 7. `orders`

| Column | Type / role | Meaning | Notes |
|---|---|---|---|
| `order_id` | Integer key | Unique order identifier | Primary identifier |
| `customer_id` | Integer FK | Customer placing the order | Links to `customers` |
| `order_date` | Date | Order date | Analysis period: 2025-01-01 to 2025-12-31 |
| `status` | Text | Delivered / Shipped / Cancelled | Delivered orders are used for realized-sales analysis |
| `payment_method` | Text | Payment method | UPI, card, wallet, net banking, COD |
| `shipping_cost` | Numeric | Estimated fulfillment/shipping cost | Counted once per order in contribution-profit analysis |
| `campaign_id` | Nullable integer FK | Optional campaign attribution | Approximately 38% of generated orders receive a campaign assignment |

## 8. `order_items`

| Column | Type / role | Meaning | Notes |
|---|---|---|---|
| `order_item_id` | Integer key | Unique line-item identifier | Primary identifier |
| `order_id` | Integer FK | Parent order | Links to `orders` |
| `product_id` | Integer FK | Product purchased | Links to `products` |
| `quantity` | Integer | Units purchased | Used in sales, COGS, and return calculations |
| `unit_price` | Numeric | Price before discount | Transactional unit price |
| `discount_pct` | Numeric | Discount percentage stored as decimal | Example: `0.10` = 10% |

## 9. `returns`

| Column | Type / role | Meaning | Notes |
|---|---|---|---|
| `return_id` | Integer key | Unique return-event identifier | Primary identifier |
| `order_id` | Integer FK | Parent order | Links to `orders` |
| `order_item_id` | Integer FK | Returned line | Links to `order_items` |
| `return_date` | Date | Return date | Generated after order date |
| `return_qty` | Integer | Units returned | Cannot exceed the original line quantity |
| `reason` | Text | Return reason | Damaged, Wrong Item, Not as Expected, Size Issue, Changed Mind |
| `refund_amount` | Numeric | Amount refunded | Used to reduce realized revenue |

## 10. Important categorical values

### Order status

```text
Delivered
Shipped
Cancelled
```

### Payment methods

```text
UPI
Credit Card
Debit Card
Net Banking
Wallet
COD
```

### Acquisition channels

```text
Organic
Paid Search
Social
Referral
Email
```

### Product categories

```text
Electronics
Home
Fashion
Beauty
Sports
```

## 11. Missing-data treatment

The generated customer data intentionally contains a small amount of missingness:

- `city`: 376 missing values.
- `acquisition_channel`: 296 missing values.

These records are retained because the missing fields do not prevent core order, revenue, product, or profitability analysis.

## 12. Analysis-period note

The order dataset covers the full calendar year 2025:

```text
2025-01-01 through 2025-12-31
```

Historical calculations such as churn or inactivity should therefore use an explicit analysis end date such as `DATE '2025-12-31'`, rather than `CURRENT_DATE`. This keeps the project reproducible and avoids changing results as time passes.
