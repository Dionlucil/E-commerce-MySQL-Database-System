# E-commerce MySQL Database System

## Overview
This project implements a simple e-commerce database system using MySQL. It covers the management of customers, products, categories, orders, payments, and product images. The database schema includes proper relationships, constraints, and sample data to demonstrate functionality.

## Features
- Relational database schema for an e-commerce system
- Tables include:
  - `customers`
  - `addresses`
  - `categories`
  - `products`
  - `orders`
  - `order_items`
  - `payments`
  - `product_images`
- Constraints: PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL, CHECK
- Sample data for testing
- Computed fields (`line_total`) using generated columns
- Indexes for faster query performance

## Prerequisites
- MySQL Server 8.0 or higher
- MySQL client or terminal access

## Setup Instructions
1. Clone or download this repository.
2. Open a terminal in the project folder.
3. Run the SQL script to create the database and tables:

```bash
mysql -u root -p < assignment_solution.sql
