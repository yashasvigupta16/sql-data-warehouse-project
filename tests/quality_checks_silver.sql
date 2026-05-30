/*
==================================================================================================
Quality Checks
==================================================================================================
Script Purpose:
   This script performs various quality checks for data consistency, accuracy,and 
   standardisation across the 'Silver' Schemas. It includes checks for:
   - Null or Duplicate primary keys.
   - Unwanted spaces in string fields.
   - Data standardisation and consistency.
   - Invalid data ranges and orders.
   - Data consistency between related fields.

Usage Notes:
  - Run these checks after data loading Silver Layer.
  - Investigate and resolve any discrepancies found during the checks.
==================================================================================================
*/

-- =========================================================================
-- Checking 'silver.crm_cust_info'
-- =========================================================================
-- Check for NULLS or Duplicates in Primary Key 
-- Expectation: No Result
SELECT
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

--Check for Unwanted Spaces
--Expectation: No Results
SELECT
    cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

--Data Standardisation & Consistency
SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info

-- =========================================================================
-- Checking 'silver.crm_prd_info'
-- =========================================================================
-- Check for NULLS or Duplicates in Primary Key 
-- Expectation: No Result
SELECT
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 AND prd_id IS NULL;

-- Checking Unwanted Spaces
--Expectation: No Results
SELECT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

--Check for NULLS or Negative Numbers in cost
--Expectation: No Results
SELECT
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

--Data Standardisation & Consistency
SELECT DISTINCT  
    prd_line
FROM silver.crm_prd_info;

--Check for Invalid Date Orders (Start Date > End Date)
SELECT
    *
FROM silver.crm_prd_info
WHERE  prd_end_date < prd_start_dt;

-- =========================================================================
-- Checking 'silver.crm_sales_details'
-- =========================================================================
--Check for Invalid Dates
--Expectation: No Invalid Dates
SELECT
    NULLIF(sls_order_dt,0)
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0
    OR LEN(sls_order_dt) != 8 
    OR sls_order_dt > 20500101
    OR sls_order_dt < 19900101;

--Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
--Expectation: No Results
SELECT
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_due_dt 
    OR sls_order_dt > sls_ship_dt

--Checking Data Consistency Between Sales,Quantity & Price
-- >> Sales = Quantity * Price
-- >> Values must not be Null ,Zero, or Negative.
-- Expectation: No Results
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price,
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
    OR sls_sales IS NULL 
    OR sls_quantity IS NULL
    OR sls_price IS NULL
    OR sls_sales <= 0
    OR sls_quantity <= 0
    OR sls_price <= 0
    ORDER BY sls_sales, sls_quantity, sls_price

-- =========================================================================
-- Checking 'silver.erp_cust_az12'
-- =========================================================================
-- Identify Out-of-Range Dates
-- Expectation: Birtdates between 1924-01-01 and Today
SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
    OR bdate > GETDATE();

-- Data standardisation & Consistency
SELECT DISTINCT
    gen
FROM silver.erp_cust_az12;

-- =========================================================================
-- Checking 'silver.erp_loc_a101'
-- =========================================================================
-- Data standardisation & Consistency
SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- =========================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- =========================================================================
--Check for Unwanted spaces
--Expectation: No Results
SELECT
    *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
    OR subcat != TRIM(subcat)
    OR maintenance != TRIM(maintenance);

-- Data standardisation & Consistency
SELECT DISTINCT
    maintenance
FROM silver.erp_px_cat_g1v2;







