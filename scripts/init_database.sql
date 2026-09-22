/*
================================================================================
Script Name:     init_database.sql
Project:         Data Warehouse and Analytics Project
Description:     This script creates the DataWarehouse database and its schemas
                 (bronze, silver, and gold) for the data warehouse project.

Purpose:         Set up the initial database structure required for the project.

WARNING:         Running this script will DROP the existing 'DataWarehouse'
                 database if it already exists. All data stored in this database
                 will be permanently deleted.

                 Make sure you have a backup before executing this script
                 in an environment containing important data.

================================================================================
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO
