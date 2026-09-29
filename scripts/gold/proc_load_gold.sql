/*
===============================================================================
Stored Procedure: Load Gold Layer
===============================================================================
Script Purpose:
    This stored procedure loads business-ready data from the Silver layer
    into the Gold layer.

    The Gold layer follows a star schema consisting of:

        - Customer Dimension
        - Product Dimension
        - Sales Fact

===============================================================================
*/

CREATE OR ALTER PROCEDURE gold.load_gold AS
BEGIN

    DECLARE
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '================================================';
        PRINT 'Loading Gold Layer';
        PRINT '================================================';


        -- ==============================================================
        -- LOAD CUSTOMER DIMENSION
        -- ==============================================================

        PRINT '------------------------------------------------';
        PRINT 'Loading Customer Dimension';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();

        TRUNCATE TABLE gold.dim_customers;

        INSERT INTO gold.dim_customers (
            customer_key,
            customer_id,
            customer_number,
            first_name,
            last_name,
            country,
            gender,
            birth_date,
            create_date
        )
        SELECT
            ROW_NUMBER() OVER (
                ORDER BY c.cst_id
            ) AS customer_key,

            c.cst_id AS customer_id,

            c.cst_key AS customer_number,

            c.cst_firstname AS first_name,

            c.cst_lastname AS last_name,

            ISNULL(l.cntry, 'n/a') AS country,

            CASE
                WHEN c.cst_gender = 'n/a'
                    THEN ISNULL(e.gen, 'n/a')
                ELSE c.cst_gender
            END AS gender,

            e.bdate AS birth_date,

            c.cst_create_date AS create_date

        FROM silver.crm_cust_info c

        LEFT JOIN silver.erp_cust_az12 e
            ON c.cst_key = e.cid

        LEFT JOIN silver.erp_loc_a101 l
            ON c.cst_key = l.cid;

        SET @end_time = GETDATE();

        PRINT 'Load Duration: '
              + CAST(
                    DATEDIFF(SECOND, @start_time, @end_time)
                    AS NVARCHAR
                )
              + ' seconds';


        -- ==============================================================
        -- LOAD PRODUCT DIMENSION
        -- ==============================================================

        PRINT '------------------------------------------------';
        PRINT 'Loading Product Dimension';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();

        TRUNCATE TABLE gold.dim_products;

        INSERT INTO gold.dim_products (
            product_key,
            product_id,
            product_number,
            product_name,
            category_id,
            category,
            subcategory,
            maintenance,
            product_cost,
            product_line,
            start_date,
            end_date
        )
        SELECT
            ROW_NUMBER() OVER (
                ORDER BY p.prd_start_dt, p.prd_key
            ) AS product_key,

            p.prd_id AS product_id,

            p.prd_key AS product_number,

            p.prd_nm AS product_name,

            p.cat_id AS category_id,

            ISNULL(pc.cat, 'n/a') AS category,

            ISNULL(pc.subcat, 'n/a') AS subcategory,

            ISNULL(pc.maintenance, 'n/a') AS maintenance,

            p.prd_cost AS product_cost,

            p.prd_line AS product_line,

            p.prd_start_dt AS start_date,

            p.prd_end_dt AS end_date

        FROM silver.crm_prd_info p

        LEFT JOIN silver.erp_px_cat_g1v2 pc
            ON p.cat_id = pc.id;

        SET @end_time = GETDATE();

        PRINT 'Load Duration: '
              + CAST(
                    DATEDIFF(SECOND, @start_time, @end_time)
                    AS NVARCHAR
                )
              + ' seconds';


        -- ==============================================================
        -- LOAD SALES FACT
        -- ==============================================================

        PRINT '------------------------------------------------';
        PRINT 'Loading Sales Fact';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();

        TRUNCATE TABLE gold.fact_sales;

        INSERT INTO gold.fact_sales (
            order_number,
            product_key,
            customer_key,
            order_date,
            shipping_date,
            due_date,
            sales_amount,
            quantity,
            price
        )
        SELECT
            s.sls_ord_num AS order_number,

            p.product_key,

            c.customer_key,

            s.sls_order_dt AS order_date,

            s.sls_ship_dt AS shipping_date,

            s.sls_due_dt AS due_date,

            s.sls_sales AS sales_amount,

            s.sls_quantity AS quantity,

            s.sls_price AS price

        FROM silver.crm_sales_details s

        LEFT JOIN gold.dim_products p
            ON s.sls_prd_key = p.product_number

        LEFT JOIN gold.dim_customers c
            ON s.sls_cust_id = c.customer_id;

        SET @end_time = GETDATE();

        PRINT 'Load Duration: '
              + CAST(
                    DATEDIFF(SECOND, @start_time, @end_time)
                    AS NVARCHAR
                )
              + ' seconds';


        -- ==============================================================
        -- COMPLETION MESSAGE
        -- ==============================================================

        SET @batch_end_time = GETDATE();

        PRINT '================================================';
        PRINT 'Gold Layer Load Completed';
        PRINT 'Total Batch Duration: '
              + CAST(
                    DATEDIFF(
                        SECOND,
                        @batch_start_time,
                        @batch_end_time
                    )
                    AS NVARCHAR
                )
              + ' seconds';
        PRINT '================================================';

    END TRY

    BEGIN CATCH

        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING GOLD LOAD';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT '================================================';

        THROW;

    END CATCH

END;
