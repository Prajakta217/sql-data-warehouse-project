/*
===============================================================================
DDL Script: Create Gold Layer Tables
===============================================================================
Script Purpose:
    This script creates the Gold layer tables for the data warehouse.

    The Gold layer contains business-ready data organized into a star schema.

    Dimension Tables:
        - gold.dim_customers
        - gold.dim_products

    Fact Table:
        - gold.fact_sales

WARNING:
    Running this script will drop the existing Gold tables if they exist.
===============================================================================
*/


-- =============================================================================
-- CREATE CUSTOMER DIMENSION
-- =============================================================================

IF OBJECT_ID('gold.dim_customers', 'U') IS NOT NULL
    DROP TABLE gold.dim_customers;

CREATE TABLE gold.dim_customers (
    customer_key    INT,
    customer_id     INT,
    customer_number NVARCHAR(50),
    first_name      NVARCHAR(50),
    last_name       NVARCHAR(50),
    country         NVARCHAR(50),
    gender          NVARCHAR(50),
    birth_date      DATE,
    create_date     DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);


-- =============================================================================
-- CREATE PRODUCT DIMENSION
-- =============================================================================

IF OBJECT_ID('gold.dim_products', 'U') IS NOT NULL
    DROP TABLE gold.dim_products;

CREATE TABLE gold.dim_products (
    product_key     INT,
    product_id      INT,
    product_number  NVARCHAR(50),
    product_name    NVARCHAR(100),
    category_id     NVARCHAR(50),
    category        NVARCHAR(50),
    subcategory     NVARCHAR(50),
    maintenance     NVARCHAR(50),
    product_cost    INT,
    product_line    NVARCHAR(50),
    start_date      DATE,
    end_date        DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);


-- =============================================================================
-- CREATE SALES FACT TABLE
-- =============================================================================

IF OBJECT_ID('gold.fact_sales', 'U') IS NOT NULL
    DROP TABLE gold.fact_sales;

CREATE TABLE gold.fact_sales (
    order_number    NVARCHAR(50),
    product_key     INT,
    customer_key    INT,
    order_date      DATE,
    shipping_date   DATE,
    due_date        DATE,
    sales_amount    INT,
    quantity        INT,
    price           INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
