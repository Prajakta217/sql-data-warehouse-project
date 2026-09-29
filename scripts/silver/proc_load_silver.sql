/*
===============================================================================
Stored Procedure: Load Silver Layer
===============================================================================
Script Purpose:
    This stored procedure loads transformed and cleaned data from the Bronze
    layer into the Silver layer.

    The procedure performs:
    - Data cleansing
    - Standardization
    - Duplicate handling
    - NULL handling
    - Data type conversions
    - Business-rule transformations
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

    DECLARE 
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';


        -- ==============================================================
        -- CRM CUSTOMER INFO
        -- ==============================================================

        PRINT '------------------------------------------------';
        PRINT 'Loading CRM Customer Info';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.crm_cust_info;

        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_material_status,
            cst_gender,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE
                WHEN UPPER(TRIM(cst_material_status)) = 'S'
                    THEN 'Single'
                WHEN UPPER(TRIM(cst_material_status)) = 'M'
                    THEN 'Married'
                ELSE 'n/a'
            END,
            CASE
                WHEN UPPER(TRIM(cst_gender)) IN ('M', 'MALE')
                    THEN 'Male'
                WHEN UPPER(TRIM(cst_gender)) IN ('F', 'FEMALE')
                    THEN 'Female'
                ELSE 'n/a'
            END,
            cst_create_date
        FROM (
            SELECT *,
                ROW_NUMBER() OVER (
                    PARTITION BY cst_id
                    ORDER BY cst_create_date DESC
                ) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flag_last = 1;

        SET @end_time = GETDATE();

        PRINT 'Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';


        -- ==============================================================
        -- CRM PRODUCT INFO
        -- ==============================================================

        PRINT '------------------------------------------------';
        PRINT 'Loading CRM Product Info';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.crm_prd_info;

        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,

            REPLACE(
                SUBSTRING(prd_key, 1, 5),
                '-',
                '_'
            ) AS cat_id,

            SUBSTRING(
                prd_key,
                7,
                LEN(prd_key)
            ) AS prd_key,

            TRIM(prd_nm),

            ISNULL(prd_cost, 0),

            CASE
                WHEN UPPER(TRIM(prd_line)) = 'M'
                    THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R'
                    THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S'
                    THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T'
                    THEN 'Touring'
                ELSE 'n/a'
            END,

            prd_start_dt,

            DATEADD(
                DAY,
                -1,
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                )
            )

        FROM bronze.crm_prd_info
        WHERE prd_id IS NOT NULL;

        SET @end_time = GETDATE();

        PRINT 'Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';


        -- ==============================================================
        -- CRM SALES DETAILS
        -- ==============================================================

        PRINT '------------------------------------------------';
        PRINT 'Loading CRM Sales Details';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.crm_sales_details;

        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            CASE
                WHEN sls_order_dt = 0
                    THEN NULL
                ELSE CONVERT(DATE, CONVERT(VARCHAR, sls_order_dt))
            END,

            CASE
                WHEN sls_ship_dt = 0
                    THEN NULL
                ELSE CONVERT(DATE, CONVERT(VARCHAR, sls_ship_dt))
            END,

            CASE
                WHEN sls_due_dt = 0
                    THEN NULL
                ELSE CONVERT(DATE, CONVERT(VARCHAR, sls_due_dt))
            END,

            CASE
                WHEN sls_sales IS NULL
                    OR sls_sales <= 0
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END,

            sls_quantity,

            CASE
                WHEN sls_price IS NULL
                    OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END

        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();

        PRINT 'Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';


        -- ==============================================================
        -- ERP CUSTOMER
        -- ==============================================================

        PRINT '------------------------------------------------';
        PRINT 'Loading ERP Customer';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.erp_cust_az12;

        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT
            CASE
                WHEN cid LIKE 'NAS%'
                    THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END,

            CASE
                WHEN bdate > GETDATE()
                    THEN NULL
                ELSE bdate
            END,

            CASE
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')
                    THEN 'Male'
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE')
                    THEN 'Female'
                ELSE 'n/a'
            END

        FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();

        PRINT 'Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';


        -- ==============================================================
        -- ERP LOCATION
        -- ==============================================================

        PRINT '------------------------------------------------';
        PRINT 'Loading ERP Location';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.erp_loc_a101;

        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            REPLACE(cid, '-', ''),
            CASE
                WHEN TRIM(cntry) IN ('DE')
                    THEN 'Germany'
                WHEN TRIM(cntry) IN ('US', 'USA')
                    THEN 'United States'
                WHEN TRIM(cntry) IN ('AU')
                    THEN 'Australia'
                WHEN TRIM(cntry) = ''
                    OR cntry IS NULL
                    THEN 'n/a'
                ELSE TRIM(cntry)
            END
        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();

        PRINT 'Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';


        -- ==============================================================
        -- ERP PRODUCT CATEGORY
        -- ==============================================================

        PRINT '------------------------------------------------';
        PRINT 'Loading ERP Product Category';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            TRIM(cat),
            TRIM(subcat),
            TRIM(maintenance)
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();

        PRINT 'Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';


        SET @batch_end_time = GETDATE();

        PRINT '================================================';
        PRINT 'Silver Layer Load Completed';
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
        PRINT 'ERROR OCCURRED DURING SILVER LOAD';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT '================================================';

        THROW;

    END CATCH

END;
