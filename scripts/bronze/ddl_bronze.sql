/*
=============================================================
DDL Script
=============================================================
Script Purpose:
    This script creates the required Bronze layer tables
    for the Data Warehouse project.

    It first checks whether each table already exists.
    If the table exists, it is dropped and recreated with
    the required columns and data types.

    The script creates tables for:
    - CRM customer information
    - CRM product information
    - CRM sales details
    - ERP customer location
    - ERP customer information
    - ERP product category information

WARNING:
    This script drops existing Bronze layer tables before
    recreating them. Any existing data in these tables will
    be permanently deleted.

    Make sure this script is executed only when recreating
    the Bronze layer structure is intended.
=============================================================
*/

if object_id ('bronze.crm_cust_info', 'U') is not null
    drop table bronze.crm_cust_info;
create table bronze.crm_cust_info (
cst_id int,
cst_key nvarchar(50),
cst_firstname nvarchar(50),
cst_lastname nvarchar(50),
cst_material_status nvarchar(50),
cst_gender nvarchar (50),
cst_create_date date
);

if object_id ('bronze.crm_prd_info', 'U') is not null
    drop table bronze.crm_prd_info;

create table bronze.crm_prd_info (
prd_id int,
prd_key nvarchar(50),
prd_nm nvarchar(50),
prd_cost int,
prd_line nvarchar(50),
prd_start_dt datetime,
prd_end_dat datetime
);

if object_id ('bronze.crm_sales_details', 'U') is not null
    drop table bronze.crm_sales_details;
create table bronze.crm_sales_details(
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cst_id int,
sls_ord_dt int,
sls_ship_dt int,
sls_due_dt int,
sls_sales int,
sls_quantity int,
sls_price int
);

if object_id ('bronze.erp_loc_a101', 'U') is not null
    drop table bronze.erp_loc_a101;
create table bronze.erp_loc_a101(
cid nvarchar(50),
cntry nvarchar(50)
);


if object_id ('bronze.erp_cust_az12', 'U') is not null
    drop table bronze.erp_cust_az12;
create table bronze.erp_cust_az12(
cid nvarchar(50),
bdate date,
gen nvarchar(50)
);

if object_id ('bronze.erp_px_cat_g1v2', 'U') is not null
    drop table bronze.erp_px_cat_g1v2;
create table bronze.erp_px_cat_g1v2(
id nvarchar(50),
cat nvarchar(50),
subcat nvarchar(50),
maintenance nvarchar(50)
);
