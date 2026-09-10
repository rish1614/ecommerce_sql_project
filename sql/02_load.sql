-- Run this file with psql after changing DATA_PATH.
-- Example:
-- \copy customers FROM '/absolute/path/data/customers.csv' CSV HEADER

\copy customers FROM 'data/customers.csv' CSV HEADER
\copy products FROM 'data/products.csv' CSV HEADER
\copy campaigns FROM 'data/campaigns.csv' CSV HEADER
\copy orders FROM 'data/orders.csv' CSV HEADER
\copy order_items FROM 'data/order_items.csv' CSV HEADER
\copy returns FROM 'data/returns.csv' CSV HEADER
