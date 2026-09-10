DROP TABLE IF EXISTS returns CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS campaigns CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    signup_date DATE NOT NULL,
    gender VARCHAR(20),
    age INT,
    city TEXT,
    state TEXT NOT NULL,
    region TEXT NOT NULL,
    acquisition_channel TEXT
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL,
    subcategory TEXT NOT NULL,
    brand TEXT NOT NULL,
    unit_cost NUMERIC(12,2) NOT NULL,
    list_price NUMERIC(12,2) NOT NULL
);

CREATE TABLE campaigns (
    campaign_id INT PRIMARY KEY,
    campaign_name TEXT NOT NULL,
    channel TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget NUMERIC(14,2) NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('Delivered','Shipped','Cancelled')),
    payment_method TEXT NOT NULL,
    shipping_cost NUMERIC(12,2) NOT NULL,
    campaign_id INT REFERENCES campaigns(campaign_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL,
    discount_pct NUMERIC(5,2) NOT NULL CHECK (discount_pct >= 0 AND discount_pct <= 1)
);

CREATE TABLE returns (
    return_id INT PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    order_item_id INT NOT NULL REFERENCES order_items(order_item_id),
    return_date DATE NOT NULL,
    return_qty INT NOT NULL CHECK (return_qty > 0),
    reason TEXT NOT NULL,
    refund_amount NUMERIC(12,2) NOT NULL CHECK (refund_amount >= 0)
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_campaign ON orders(campaign_id);
CREATE INDEX idx_items_order ON order_items(order_id);
CREATE INDEX idx_items_product ON order_items(product_id);
CREATE INDEX idx_returns_order_item ON returns(order_item_id);
