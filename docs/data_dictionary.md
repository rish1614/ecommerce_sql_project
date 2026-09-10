# Data Dictionary

## customers
| Column | Meaning |
|---|---|
| customer_id | Unique customer key |
| customer_name | Customer display name |
| signup_date | Customer registration date |
| gender | Gender category |
| age | Customer age |
| city | Customer city; intentionally has a small amount of missing data |
| state | Customer state |
| region | North / South / East / West |
| acquisition_channel | Initial acquisition channel; intentionally has a small amount of missing data |

## products
| Column | Meaning |
|---|---|
| product_id | Unique product key |
| product_name | Product label |
| category | Main product category |
| subcategory | Product subcategory |
| brand | Brand label |
| unit_cost | Estimated cost to the business |
| list_price | Listed selling price |

## campaigns
| Column | Meaning |
|---|---|
| campaign_id | Campaign key |
| campaign_name | Campaign label |
| channel | Campaign channel |
| start_date | Campaign start |
| end_date | Campaign end |
| budget | Campaign budget |

## orders
| Column | Meaning |
|---|---|
| order_id | Unique order key |
| customer_id | Customer foreign key |
| order_date | Order date |
| status | Delivered / Shipped / Cancelled |
| payment_method | Payment method |
| shipping_cost | Estimated fulfillment/shipping cost |
| campaign_id | Optional campaign attribution |

## order_items
| Column | Meaning |
|---|---|
| order_item_id | Unique line-item key |
| order_id | Order foreign key |
| product_id | Product foreign key |
| quantity | Units purchased |
| unit_price | Price before discount |
| discount_pct | Discount as decimal, e.g. 0.10 = 10% |

## returns
| Column | Meaning |
|---|---|
| return_id | Unique return event key |
| order_id | Order foreign key |
| order_item_id | Returned line-item foreign key |
| return_date | Return date |
| return_qty | Units returned |
| reason | Return reason |
| refund_amount | Money refunded to customer |
