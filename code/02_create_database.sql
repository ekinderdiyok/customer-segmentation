/**********************************************************************************************
 *                                   CUSTOMER DATABASE SETUP
 * Author: Ekin Derdiyok
 * Date: 2024-07-20 (start)
 * Email: ekin.derdiyok@icloud.com
 * GitHub: github.com/ekinderdiyok/customer-segmentation

 * Description: This script creates and populates the customer database for segmentation analysis. 
 * It includes the creation of tables, data import commands, and data validation checks.
 * Note: The CSV files contain mock data created by the Python script in the same repository.
 * Generate data using the Python script before running the data import commands or simply
 * download the CSV files from the data folder.
 **********************************************************************************************/

-- Table of Contents:
-- 1. Database Setup
-- 2. Table Creation and Setup
-- 3. Data Import Commands
-- 4. Data Validation and Integrity Checks

/**********************************************************************************************
 *                                      DATABASE SETUP
 **********************************************************************************************/

-- Create database. Run the following command in the psql terminal
CREATE DATABASE IF NOT EXISTS customer_db;

-- Connect to customer_db. Run the following command in the psql terminal
\c customer_db;

/**********************************************************************************************
 *                                  TABLE CREATION AND SETUP
 **********************************************************************************************/

-- Delete existing tables in customer_db if they exist
DROP TABLE IF EXISTS customer_loyalty;
DROP TABLE IF EXISTS loyalty_programs;
DROP TABLE IF EXISTS order_brands;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS brands;
DROP TABLE IF EXISTS customers;

-- Create customers table
CREATE TABLE IF NOT EXISTS customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE NOT NULL,
    registration_date DATE DEFAULT CURRENT_DATE,
    gender CHAR(1),
    birth_date DATE,
    is_newsletter BOOLEAN DEFAULT FALSE,
    postal_code VARCHAR(10),
    country_code CHAR(2),
    is_plus_member BOOLEAN DEFAULT FALSE
);

-- Create brands table
CREATE TABLE IF NOT EXISTS brands (
    brand_id SERIAL PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE DEFAULT CURRENT_DATE,
    total_amount DECIMAL(10, 2) NOT NULL,
    is_onsite BOOLEAN DEFAULT FALSE  -- If the order was made in the physical store
);

-- Create order_brands table to link orders and brands
CREATE TABLE IF NOT EXISTS order_brands (
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    brand_id INT REFERENCES brands(brand_id) ON DELETE CASCADE,
    PRIMARY KEY (order_id, brand_id)
);

-- Create loyalty_programs table
CREATE TABLE IF NOT EXISTS loyalty_programs (
    program_id SERIAL PRIMARY KEY,
    program_name VARCHAR(100) NOT NULL,
    description TEXT
);

-- Create customer_loyalty table linking customers and loyalty_programs
CREATE TABLE IF NOT EXISTS customer_loyalty (
    customer_id INT REFERENCES customers(customer_id) ON DELETE CASCADE,
    program_id INT REFERENCES loyalty_programs(program_id) ON DELETE CASCADE,
    membership_start_date DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY (customer_id, program_id)
);

/**********************************************************************************************
 *                                   DATA IMPORT COMMANDS
 **********************************************************************************************/

-- Populate customers table with data
\COPY customers (customer_id, name, email, registration_date, gender, birth_date, is_newsletter, postal_code, country_code, is_plus_member)
FROM '/Users/ekinderdiyok/Documents/projects/customer-segmentation/data/customers.csv'
WITH (FORMAT csv, HEADER true);

-- Populate brands table with data
\COPY brands (brand_id, brand_name)
FROM '/Users/ekinderdiyok/Documents/projects/customer-segmentation/data/brands.csv'
WITH (FORMAT csv, HEADER true);

-- Populate orders table with data
\COPY orders (order_id, customer_id, order_date, total_amount, is_onsite)
FROM '/Users/ekinderdiyok/Documents/projects/customer-segmentation/data/orders.csv'
WITH (FORMAT csv, HEADER true);

-- Populate order_brands table with data
\COPY order_brands (order_id, brand_id)
FROM '/Users/ekinderdiyok/Documents/projects/customer-segmentation/data/order_brands.csv'
WITH (FORMAT csv, HEADER true);

-- Populate loyalty_programs table with data
\COPY loyalty_programs (program_id, program_name, description)
FROM '/Users/ekinderdiyok/Documents/projects/customer-segmentation/data/loyalty_programs.csv'
WITH (FORMAT csv, HEADER true);

-- Populate customer_loyalty table with data
\COPY customer_loyalty (customer_id, program_id, membership_start_date)
FROM '/Users/ekinderdiyok/Documents/projects/customer-segmentation/data/customer_loyalty.csv'
WITH (FORMAT csv, HEADER true);

/**********************************************************************************************
 *                            DATA VALIDATION AND INTEGRITY CHECKS
 **********************************************************************************************/

-- Check if the database was created
SELECT datname
FROM pg_database
WHERE datname = 'customer_db';

-- Check if the tables were created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('customers', 'orders', 'brands', 'order_brands', 'loyalty_programs', 'customer_loyalty');

-- Check the columns and their data types in the customers table
SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'customers';

-- Check the columns and their data types in the brands table
SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'brands';

-- Check the columns and their data types in the orders table
SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'orders';

-- Check the columns and their data types in the order_brands table
SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'order_brands';

-- Check the columns and their data types in the loyalty_programs table
SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'loyalty_programs';

-- Check the columns and their data types in the customer_loyalty table
SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'customer_loyalty';

-- Check for NOT NULL constraints in customers table
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'customers' AND is_nullable = 'NO';

-- Check for NOT NULL constraints in brands table
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'brands' AND is_nullable = 'NO';

-- Check for NOT NULL constraints in orders table
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'orders' AND is_nullable = 'NO';

-- Check for NOT NULL constraints in order_brands table
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'order_brands' AND is_nullable = 'NO';

-- Check for NOT NULL constraints in loyalty_programs table
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'loyalty_programs' AND is_nullable = 'NO';

-- Check for NOT NULL constraints in customer_loyalty table
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'customer_loyalty' AND is_nullable = 'NO';

-- Check for foreign key constraints in customer_loyalty table
SELECT 
    tc.constraint_name, 
    kcu.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name, 
    ccu.column_name AS foreign_column_name
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
WHERE 
    tc.table_name = 'customer_loyalty' 
    AND tc.constraint_type = 'FOREIGN KEY';

-- Check for unique constraint on email in customers table
SELECT conname, conkey
FROM pg_constraint
WHERE conrelid = 'customers'::regclass AND contype = 'u';

-- Check if the customers table was populated
SELECT COUNT(*) AS customer_count
FROM customers;

-- Check if the brands table was populated
SELECT COUNT(*) AS brand_count
FROM brands;

-- Check if the orders table was populated
SELECT COUNT(*) AS order_count
FROM orders;

-- Check if the order_brands table was populated
SELECT COUNT(*) AS order_brands_count
FROM order_brands;

-- Check if the loyalty_programs table was populated
SELECT COUNT(*) AS loyalty_program_count
FROM loyalty_programs;

-- Check if the customer_loyalty table was populated
SELECT COUNT(*) AS customer_loyalty_count
FROM customer_loyalty;

-- Check for invalid email formats in customers table
SELECT email
FROM customers
WHERE email NOT LIKE '%_@__%.__%';

-- Check for any customer_id in orders table that does not exist in customers table
SELECT customer_id
FROM orders
WHERE customer_id NOT IN (SELECT customer_id FROM customers);

-- Check for any order_id or brand_id in order_brands table that does not exist in orders or brands table
SELECT order_id
FROM order_brands
WHERE order_id NOT IN (SELECT order_id FROM orders);

SELECT brand_id
FROM order_brands
WHERE brand_id NOT IN (SELECT brand_id FROM brands);

-- Check for any customer_id or program_id in customer_loyalty table that does not exist in customers or loyalty_programs table
SELECT customer_id
FROM customer_loyalty
WHERE customer_id NOT IN (SELECT customer_id FROM customers);

SELECT program_id
FROM customer_loyalty
WHERE program_id NOT IN (SELECT program_id FROM loyalty_programs);

/**********************************************************************************************
 *                            QUERY FOR K-MEANS CLUSTERING
 **********************************************************************************************/

WITH customer_ages AS (
    SELECT 
        customer_id,
        EXTRACT(YEAR FROM AGE(birth_date)) AS age
    FROM customers
),
nike_loyalty AS (
    SELECT 
        cl.customer_id,
        TRUE AS is_nike
    FROM customer_loyalty cl
    JOIN loyalty_programs lp ON cl.program_id = lp.program_id
    WHERE lp.program_name = 'Nike'
),
polo_loyalty AS (
    SELECT 
        cl.customer_id,
        TRUE AS is_polo
    FROM customer_loyalty cl
    JOIN loyalty_programs lp ON cl.program_id = lp.program_id
    WHERE lp.program_name = 'Polo Ralph Lauren'
),
order_stats AS (
    SELECT 
        customer_id,
        AVG(total_amount) AS avg_order_amount,
        COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id
)

SELECT 
    c.customer_id,
    COALESCE(ca.age, 0) AS age,
    COALESCE(nl.is_nike, FALSE) AS is_nike,
    COALESCE(pl.is_polo, FALSE) AS is_polo,
    COALESCE(os.avg_order_amount, 0.0) AS avg_order_amount,
    COALESCE(os.order_count, 0) AS order_count
FROM customers c
LEFT JOIN customer_ages ca ON c.customer_id = ca.customer_id
LEFT JOIN nike_loyalty nl ON c.customer_id = nl.customer_id
LEFT JOIN polo_loyalty pl ON c.customer_id = pl.customer_id
LEFT JOIN order_stats os ON c.customer_id = os.customer_id
;

/**********************************************************************************************
 *                               END OF THE SCRIPT
 **********************************************************************************************/