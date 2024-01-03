-- Create a database

CREATE DATABASE EcommerceStore

-- Create schemas for database tables

CREATE SCHEMA prod;
CREATE SCHEMA cust;
CREATE SCHEMA ord;
CREATE SCHEMA stage;
CREATE SCHEMA calc;

-- Create tables in the EcommerceStore database

CREATE TABLE prod.products (
    product_id BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    product_name NVARCHAR(200),
    price DECIMAL(10, 2),
    product_description NVARCHAR(MAX),
  	stock_quantity BIGINT,
  	row_added_by NVARCHAR(200),
  	row_added_date DATETIME2(2),
  	row_updt_by NVARCHAR(200),
  	row_updt_date DATETIME2(2)
);

CREATE TABLE prod.categories_lkp (
    category_id BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    category_name NVARCHAR(200),
  	category_desc NVARCHAR(MAX),
  	row_added_by NVARCHAR(200),
  	row_added_date DATETIME2(2),
  	row_updt_by NVARCHAR(200),
  	row_updt_date DATETIME2(2)
);

CREATE TABLE prod.product_categories_mpng (
	  product_categories_id BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    product_id BIGINT,
    category_id BIGINT, 
  	row_added_by NVARCHAR(200),
  	row_added_date DATETIME2(2),
  	row_updt_by NVARCHAR(200),
  	row_updt_date DATETIME2(2)
);

CREATE TABLE cust.customers (
    customer_id BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	  customer_type_id BIGINT,
    first_name NVARCHAR(100),
    last_name NVARCHAR(100),
  	customer_login NVARCHAR(200),
  	row_added_by NVARCHAR(200),
  	row_added_date DATETIME2(2),
  	row_updt_by NVARCHAR(200),
  	row_updt_date DATETIME2(2) 
);

CREATE TABLE cust.customer_type_lkp (
  	customer_type_id BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
  	customer_type_name NVARCHAR(200),
  	customer_type_desc NVARCHAR(MAX),
  	row_added_by NVARCHAR(200),
  	row_added_date DATETIME2(2),
  	row_updt_by NVARCHAR(200),
  	row_updt_date DATETIME2(2) 
);

CREATE TABLE cust.customer_contact (
  	customer_contact_id BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
  	customer_id BIGINT,
  	customer_email_addr NVARCHAR(200),
  	customer_phone_num NVARCHAR(200),
  	row_added_by NVARCHAR(200),
  	row_added_date DATETIME2(2),
  	row_updt_by NVARCHAR(200),
  	row_updt_date DATETIME2(2) 
);

CREATE TABLE cust.addresses (
    address_id BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    customer_id BIGINT,
  	customer_addr_city NVARCHAR(100),
  	customer_addr_postal_code NVARCHAR(200),
    customer_addr_line1 NVARCHAR(300),
    customer_addr_line2 NVARCHAR(300),
  	row_added_by NVARCHAR(200),
  	row_added_date DATETIME2(2),
  	row_updt_by NVARCHAR(200),
  	row_updt_date DATETIME2(2) 
);

CREATE TABLE ord.orders (
    order_id BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    customer_id BIGINT,
  	delivery_method_id BIGINT,
  	payment_method_id BIGINT,
    order_date DATETIME2(2),
    order_status NVARCHAR(100),
  	message_to_order NVARCHAR(MAX),
  	row_added_by NVARCHAR(200),
  	row_added_date DATETIME2(2),
  	row_updt_by NVARCHAR(200),
  	row_updt_date DATETIME2(2) 
);

CREATE TABLE ord.returns (
  	return_id BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
  	customer_id BIGINT,
  	return_date DATETIME2(2),
  	return_status NVARCHAR(100),
  	message_to_return NVARCHAR(MAX),
  	row_added_by NVARCHAR(200),
  	row_added_date DATETIME2(2),
  	row_updt_by NVARCHAR(200),
  	row_updt_date DATETIME2(2) 
);

CREATE TABLE ord.order_details (
    order_details_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    order_id BIGINT,
    product_id BIGINT,
    quantity BIGINT,
  	price DECIMAL(10, 2),
    unit_price DECIMAL(10, 2),
  	row_added_by NVARCHAR(200),
  	row_added_date DATETIME2(2),
  	row_updt_by NVARCHAR(200),
  	row_updt_date DATETIME2(2) 
);

CREATE TABLE ord.delivery_methods_lkp (
  	delivery_method_id BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
  	delivery_method_name NVARCHAR(200),
  	delivery_method_desc NVARCHAR(MAX),
  	row_added_by NVARCHAR(200),
  	row_added_date DATETIME2(2),
  	row_updt_by NVARCHAR(200),
  	row_updt_date DATETIME2(2) 
);

CREATE TABLE ord.payment_methods_lkp (
  	payment_method_id BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
  	payment_method_name NVARCHAR(200),
  	payment_method_desc NVARCHAR(200),
  	row_added_by NVARCHAR(200),
  	row_added_date DATETIME2(2),
  	row_updt_by NVARCHAR(200),
  	row_updt_date DATETIME2(2) 
);

CREATE TABLE ord.reviews (
    review_id BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    product_id BIGINT,
    customer_id BIGINT,
  	review_type_id INT,
    rating BIGINT,
    comment NVARCHAR(MAX),
  	row_added_by NVARCHAR(200),
  	row_added_date DATETIME2(2),
  	row_updt_by NVARCHAR(200),
  	row_updt_date DATETIME2(2)
);

CREATE TABLE ord.review_type_lkp (
  	review_type_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
  	review_type_name NVARCHAR(200),
  	review_type_desc NVARCHAR(MAX),
  	row_added_by NVARCHAR(200),
  	row_added_date DATETIME2(2),
  	row_updt_by NVARCHAR(200),
  	row_updt_date DATETIME2(2)
);

CREATE TABLE ord.shopping_cart (
    shopping_cart_id BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    customer_id BIGINT,
    product_id BIGINT,
    quantity INT,
  	price DECIMAL(10, 2),
  	row_added_by NVARCHAR(200),
  	row_added_date DATETIME2(2),
  	row_updt_by NVARCHAR(200),
  	row_updt_date DATETIME2(2)
);

CREATE TABLE stage.stg_prod (
  	product_id BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
  	customer_id BIGINT,
  	product_name NVARCHAR(200),
  	sku NVARCHAR(250),
  	price DECIMAL(10, 2),
  	product_description NVARCHAR(MAX),
  	stock_quantity BIGINT
);

CREATE TABLE calc.prod_price_month (
  	product_id BIGINT PRIMARY KEY IDENTITY(1,1) NOT NULL,
  	customer_id BIGINT,
  	product_name NVARCHAR(200),
  	sku NVARCHAR(250),
  	price DECIMAL(10, 2),
  	product_description NVARCHAR(MAX),
  	stock_quantity BIGINT
);

