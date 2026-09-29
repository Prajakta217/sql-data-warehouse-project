/*
===============================================================================
Data Quality Checks
===============================================================================
Script Purpose:
    This script contains validation checks for the Silver and Gold layers.

    The checks help identify:
        - NULL values
        - Duplicate records
        - Invalid relationships
        - Invalid dates
        - Invalid sales values
===============================================================================
*/


-- =============================================================================
-- SILVER LAYER CHECKS
-- =============================================================================


-- Check for duplicate customer IDs

SELECT
    cst_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;


-- Check for NULL customer IDs

SELECT *
FROM silver.crm_cust_info
WHERE cst_id IS NULL;


-- Check for NULL customer keys

SELECT *
FROM silver.crm_cust_info
WHERE cst_key IS NULL;


-- Check for invalid product IDs

SELECT *
FROM silver.crm_prd_info
WHERE prd_id IS NULL;


-- Check for NULL product names

SELECT *
FROM silver.crm_prd_info
WHERE prd_nm IS NULL;


-- Check for invalid product costs

SELECT *
FROM silver.crm_prd_info
WHERE prd_cost < 0;


-- Check for invalid sales values

SELECT *
FROM silver.crm_sales_details
WHERE sls_sales <= 0;


-- Check for invalid quantities

SELECT *
FROM silver.crm_sales_details
WHERE sls_quantity <= 0;


-- Check for invalid prices

SELECT *
FROM silver.crm_sales_details
WHERE sls_price <= 0;


-- Check for invalid order dates

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > GETDATE();


-- =============================================================================
-- GOLD LAYER CHECKS
-- =============================================================================


-- Check for duplicate customer IDs in Gold

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- Check for NULL customer keys

SELECT *
FROM gold.dim_customers
WHERE customer_key IS NULL;


-- Check for NULL product keys

SELECT *
FROM gold.dim_products
WHERE product_key IS NULL;


-- Check for NULL product numbers

SELECT *
FROM gold.dim_products
WHERE product_number IS NULL;


-- Check for NULL sales order numbers

SELECT *
FROM gold.fact_sales
WHERE order_number IS NULL;


-- Check for orphan customer keys

SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;


-- Check for orphan product keys

SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;


-- Check for invalid sales amounts

SELECT *
FROM gold.fact_sales
WHERE sales_amount <= 0;


-- Check for invalid quantities

SELECT *
FROM gold.fact_sales
WHERE quantity <= 0;
