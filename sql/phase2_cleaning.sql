-- ===================================================
-- PHASE 2: CLEANING
-- ===================================================

-- ---- SECTION 1: Fix Data Type ------------------

-- Quantity is nvarchar → convert to int
ALTER TABLE blaban_data
ALTER COLUMN Quantity INT;

-- Confirm the change
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'blaban_data' AND COLUMN_NAME = 'Quantity';


-- ---- SECTION 2: Investigate Before Fixing ------

-- Count all issues in one pass
SELECT
    SUM(CASE WHEN Topping_Type IS NULL OR LTRIM(RTRIM(Topping_Type)) = '' THEN 1 ELSE 0 END)       AS topping_missing,
    SUM(CASE WHEN Membership_Status IS NULL OR LTRIM(RTRIM(Membership_Status)) = '' THEN 1 ELSE 0 END) AS membership_missing,
    SUM(CASE WHEN Customer_Gender IS NULL OR LTRIM(RTRIM(Customer_Gender)) = '' THEN 1 ELSE 0 END)  AS gender_missing,
    SUM(CASE WHEN Customer_Age IS NULL THEN 1 ELSE 0 END)                                           AS age_null,
    SUM(CASE WHEN Store_Rating IS NULL THEN 1 ELSE 0 END)                                           AS rating_null,
    SUM(CASE WHEN Customer_Age > 120 THEN 1 ELSE 0 END)                                             AS age_outlier,
    SUM(CASE WHEN Unit_Price = 9999.99 THEN 1 ELSE 0 END)                                           AS price_outlier,
    SUM(CASE WHEN Quantity < 0 THEN 1 ELSE 0 END)                                                   AS negative_qty,
    SUM(CASE WHEN Total_Sales < 0 THEN 1 ELSE 0 END)                                               AS negative_sales
FROM blaban_data;

-- Preview the actual bad rows before touching anything
SELECT Transaction_ID, Customer_Age, Unit_Price, Quantity, Total_Sales
FROM blaban_data
WHERE Customer_Age > 120
   OR Unit_Price = 9999.99
   OR Quantity < 0
   OR Total_Sales < 0;
   
-- ---- SECTION 3: Fix Nulls & Missing Values -----

-- Topping_Type → 'None' (customer simply chose none)
UPDATE blaban_data
SET Topping_Type = 'None'
WHERE Topping_Type IS NULL OR LTRIM(RTRIM(Topping_Type)) = '';

-- Membership_Status → 'None-Member' (valid Membership status)
UPDATE blaban_data
SET Membership_Status = 'None-Member'
WHERE Membership_Status IS NULL OR LTRIM(RTRIM(Membership_Status)) = '' OR Membership_Status = 'None';

-- Customer_Gender → 'Unknown' (never assume)
UPDATE blaban_data
SET Customer_Gender = 'Unknown'
WHERE Customer_Gender IS NULL OR LTRIM(RTRIM(Customer_Gender)) = '';

-- Customer_Age → avg of valid ages only (exclude outliers from the average)
UPDATE blaban_data
SET Customer_Age = (
    SELECT ROUND(AVG(Customer_Age), 0) 
    FROM blaban_data 
    WHERE Customer_Age IS NOT NULL AND Customer_Age <= 120
)
WHERE Customer_Age IS NULL;

-- Store_Rating → avg rating
UPDATE blaban_data
SET Store_Rating = (
    SELECT ROUND(AVG(Store_Rating), 1) 
    FROM blaban_data 
    WHERE Store_Rating IS NOT NULL
)
WHERE Store_Rating IS NULL;


-- ---- SECTION 4: Fix Outliers -------------------

-- Customer_Age > 120 → replace with avg of valid ages
-- (280 is clearly a typo — treated same as null)
UPDATE blaban_data
SET Customer_Age = (
    SELECT ROUND(AVG(Customer_Age), 0) 
    FROM blaban_data 
    WHERE Customer_Age IS NOT NULL AND Customer_Age <= 120
)
WHERE Customer_Age > 120;

-- Unit_Price = 9999.99 → replace with avg price of same product
-- (9999.99 is a classic placeholder/system error value)
UPDATE blaban_data
SET Unit_Price = (
    SELECT ROUND(AVG(b2.Unit_Price), 2)
    FROM blaban_data b2
    WHERE b2.Product_Name = blaban_data.Product_Name
      AND b2.Unit_Price <> 9999.99
)
WHERE Unit_Price = 9999.99;

-- ---- SECTION 5: Fix Bad Data -------------------

-- Negative Quantity → flip to positive (sign entry error)
UPDATE blaban_data
SET Quantity = ABS(Quantity)
WHERE Quantity < 0;

-- ---- SECTION 6: Recalculate Total_Sales --------

-- After fixing Unit_Price and Quantity, recalculate from scratch
-- so every financial figure is consistent and trustworthy
UPDATE blaban_data
SET Total_Sales = ROUND(
    (Unit_Price * Quantity * (1 - Discount_Rate)) + Tax_Amount
, 2);

-- ---- SECTION 7: Final Verification -------------

-- All nulls should be 0, all ranges should be valid
SELECT
    -- Null check
    SUM(CASE WHEN Topping_Type IS NULL OR LTRIM(RTRIM(Topping_Type)) = '' THEN 1 ELSE 0 END)          AS topping_missing,
    SUM(CASE WHEN Membership_Status IS NULL OR LTRIM(RTRIM(Membership_Status)) = '' THEN 1 ELSE 0 END) AS membership_missing,
    SUM(CASE WHEN Customer_Gender IS NULL OR LTRIM(RTRIM(Customer_Gender)) = '' THEN 1 ELSE 0 END)     AS gender_missing,
    SUM(CASE WHEN Customer_Age IS NULL THEN 1 ELSE 0 END)                                              AS age_missing,
    SUM(CASE WHEN Store_Rating IS NULL THEN 1 ELSE 0 END)                                              AS rating_missing,
    -- Range check
    MAX(Customer_Age)                                                                                   AS max_age,
    MAX(Unit_Price)                                                                                     AS max_price,
    MIN(Quantity)                                                                                       AS min_qty,
    MIN(Total_Sales)                                                                                    AS min_sales
FROM blaban_data;


-- Checking Total_Sales Column (this should return nothing)
SELECT Transaction_ID, Unit_Price, Quantity, Discount_Rate, Tax_Amount, Total_Sales,
    ROUND((Unit_Price * Quantity * (1 - Discount_Rate)) + Tax_Amount, 2) AS expected_sales
FROM blaban_data
WHERE ABS(Total_Sales - ROUND((Unit_Price * Quantity * (1 - Discount_Rate)) + Tax_Amount, 2)) > 0.01;