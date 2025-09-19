-- assignment_solution_fixed.sql
-- MySQL schema for a simple e-commerce system
-- Save and run: mysql -u <user> -p < assignment_solution_fixed.sql

CREATE DATABASE IF NOT EXISTS ecommerce_assignment
  CHARACTER SET = 'utf8mb4'
  COLLATE = 'utf8mb4_unicode_ci';
USE ecommerce_assignment;

-- ---------- Drop existing tables to avoid conflicts ----------
DROP TABLE IF EXISTS product_images, payments, order_items, orders, products, categories, addresses, customers;

-- ---------- Customers ----------
CREATE TABLE customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(30),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------- Addresses (1 customer -> many addresses) ----------
CREATE TABLE addresses (
  address_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  street VARCHAR(255) NOT NULL,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100),
  postal_code VARCHAR(20),
  country VARCHAR(100) NOT NULL,
  is_billing TINYINT(1) NOT NULL DEFAULT 0,
  is_shipping TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_addresses_customer FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------- Categories ----------
CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL UNIQUE,
  description TEXT NULL
) ENGINE=InnoDB;

-- ---------- Products ----------
CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  description TEXT,
  sku VARCHAR(80) NOT NULL UNIQUE,
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
  category_id INT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_products_category FOREIGN KEY (category_id)
    REFERENCES categories(category_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------- Orders (one customer can have many orders) ----------
CREATE TABLE orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  shipping_address_id INT NULL,
  billing_address_id INT NULL,
  total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
  CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_orders_ship_addr FOREIGN KEY (shipping_address_id)
    REFERENCES addresses(address_id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_orders_bill_addr FOREIGN KEY (billing_address_id)
    REFERENCES addresses(address_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------- Order Items (many-to-many: orders <> products) ----------
CREATE TABLE order_items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
  line_total DECIMAL(12,2) AS (quantity * unit_price) STORED,
  CONSTRAINT fk_orderitems_order FOREIGN KEY (order_id)
    REFERENCES orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_orderitems_product FOREIGN KEY (product_id)
    REFERENCES products(product_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE KEY ux_order_product (order_id, product_id)
) ENGINE=InnoDB;

-- ---------- Payments ----------
CREATE TABLE payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL UNIQUE,
  amount DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
  payment_method VARCHAR(50) NOT NULL,
  payment_status VARCHAR(50) NOT NULL DEFAULT 'pending',
  paid_at TIMESTAMP NULL,
  CONSTRAINT fk_payments_order FOREIGN KEY (order_id)
    REFERENCES orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------- Product Images ----------
CREATE TABLE product_images (
  image_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  url VARCHAR(255) NOT NULL,
  alt_text VARCHAR(255),
  is_primary TINYINT(1) NOT NULL DEFAULT 0,
  CONSTRAINT fk_images_product FOREIGN KEY (product_id)
    REFERENCES products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------- Indexes ----------
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orderitems_order ON order_items(order_id);
CREATE INDEX idx_orderitems_product ON order_items(product_id);

-- ---------- Sample Data ----------
INSERT INTO categories (name, description) VALUES
  ('Electronics', 'Gadgets and devices'),
  ('Books', 'Printed and electronic books');

INSERT INTO products (name, description, sku, price, stock, category_id) VALUES
  ('Wireless Headphones', 'Noise-cancelling over-ear headphones', 'WH-001', 99.99, 50, 1),
  ('Intro to Databases', 'A beginner book about DB concepts', 'BK-101', 29.50, 120, 2);

INSERT INTO customers (first_name, last_name, email, phone) VALUES
  ('Diana', 'Kemunto', 'diana.k@example.com', '+254700000000');

INSERT INTO addresses (customer_id, street, city, state, postal_code, country, is_billing, is_shipping)
VALUES (1, '1 Campus Rd', 'Nyeri', 'Nyeri County', '10101', 'Kenya', 1, 1);

INSERT INTO orders (customer_id, shipping_address_id, billing_address_id, total_amount)
VALUES (1, 1, 1, 129.49);

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (1, 1, 1, 99.99), (1, 2, 1, 29.50);

INSERT INTO payments (order_id, amount, payment_method, payment_status, paid_at)
VALUES (1, 129.49, 'card', 'completed', NOW());

-- Recompute order total
UPDATE orders o
JOIN (
  SELECT order_id, SUM(quantity * unit_price) AS calc_total
  FROM order_items
  GROUP BY order_id
) oi ON o.order_id = oi.order_id
SET o.total_amount = oi.calc_total;

-- End of file
