-- ===================================================
-- PHASE 1: Exploration
-- ===================================================

-- ---- SECTION 1: First Look -----------------

-- How many rows do we have?
SELECT COUNT(*) 
FROM blaban_data;

-- Preview the first 20 rows
SELECT TOP 5 * 
FROM blaban_data;

-- What are all the column names and data types?
SELECT COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'blaban_data';
-- Quantity column is nvarchar, we'll need to change it later

-- ---- SECTION 2: Distinct Values ------------

-- How many unique values in key columns?
SELECT
    COUNT(DISTINCT Branch)     AS unique_branch,
    COUNT(DISTINCT Product_Name)   AS unique_product,
    COUNT(DISTINCT Size)     AS unique_size,
    COUNT(DISTINCT Topping_Type) AS unique_topping,
    COUNT(DISTINCT Membership_Status) AS unique_Membership,
    COUNT(DISTINCT Payment_Method)   AS unique_Payment_Method,
    COUNT(DISTINCT Order_Source)     AS unique_Order_Source,
    COUNT(DISTINCT Category) AS unique_Category,
    COUNT(DISTINCT Region) AS unique_Region
FROM blaban_data;

-- Exploring Distinct Values
SELECT DISTINCT Branch, COUNT(*) AS count
FROM blaban_data
GROUP BY Branch
ORDER BY count DESC;

SELECT DISTINCT Product_Name, COUNT(*) AS count
FROM blaban_data
GROUP BY Product_Name
ORDER BY count DESC;

SELECT DISTINCT Size, COUNT(*) AS count
FROM blaban_data
GROUP BY Size
ORDER BY count DESC;

SELECT DISTINCT Topping_Type, COUNT(*) AS count
FROM blaban_data
GROUP BY Topping_Type
ORDER BY count DESC;

SELECT DISTINCT Membership_Status, COUNT(*) AS count
FROM blaban_data
GROUP BY Membership_Status
ORDER BY count DESC;

SELECT DISTINCT Payment_Method, COUNT(*) AS count
FROM blaban_data
GROUP BY Payment_Method
ORDER BY count DESC;

SELECT DISTINCT Order_Source, COUNT(*) AS count
FROM blaban_data
GROUP BY Order_Source
ORDER BY count DESC;

SELECT DISTINCT Category, COUNT(*) AS count
FROM blaban_data
GROUP BY Category
ORDER BY count DESC;

SELECT DISTINCT Customer_Gender, COUNT(*) AS count
FROM blaban_data
GROUP BY Customer_Gender
ORDER BY count DESC;

SELECT DISTINCT Region, COUNT(*) AS count
FROM blaban_data
GROUP BY Region
ORDER BY count DESC;

--What is out data range ?
SELECT MIN(DATE_TIME),MAX(DATE_TIME)
FROM blaban_data

-- ---- SECTION 3: Null & Missing Audit -------

SELECT 
    -- TEXT columns → trim properly
    SUM(CASE WHEN Product_Name     IS NULL OR LTRIM(RTRIM(Product_Name))     = '' THEN 1 ELSE 0 END) AS Product_Name_missing,
    SUM(CASE WHEN Branch   IS NULL OR LTRIM(RTRIM(Branch))   = '' THEN 1 ELSE 0 END) AS Branch_missing,
    SUM(CASE WHEN Size     IS NULL OR LTRIM(RTRIM(Size))     = '' THEN 1 ELSE 0 END) AS Size_missing,
    SUM(CASE WHEN Topping_Type IS NULL OR LTRIM(RTRIM(Topping_Type)) = '' THEN 1 ELSE 0 END) AS Topping_Type_missing,
    SUM(CASE WHEN Membership_Status IS NULL OR LTRIM(RTRIM(Membership_Status)) = '' THEN 1 ELSE 0 END) AS Membership_Status_missing,
    SUM(CASE WHEN Payment_Method     IS NULL OR LTRIM(RTRIM(Payment_Method)) = '' THEN 1 ELSE 0 END) AS Payment_Method_missing,
    SUM(CASE WHEN Order_Source   IS NULL OR LTRIM(RTRIM(Order_Source))   = '' THEN 1 ELSE 0 END) AS Order_Source_missing,
    SUM(CASE WHEN Category     IS NULL OR LTRIM(RTRIM(Category)) = '' THEN 1 ELSE 0 END) AS Category_missing,
    SUM(CASE WHEN Region IS NULL OR LTRIM(RTRIM(Region)) = '' THEN 1 ELSE 0 END) AS Region_missing,
    SUM(CASE WHEN Quantity IS NULL OR LTRIM(RTRIM(Quantity)) = '' THEN 1 ELSE 0 END) AS Quantity_missing,
    SUM(CASE WHEN Customer_Gender IS NULL OR LTRIM(RTRIM(Customer_Gender)) = '' THEN 1 ELSE 0 END) AS Customer_Gender_missing,
    -- NUMERIC columns → only check NULL
    SUM(CASE WHEN Transaction_ID IS NULL THEN 1 ELSE 0 END) AS Transaction_ID_missing,
    SUM(CASE WHEN Unit_Price  IS NULL THEN 1 ELSE 0 END) AS Unit_Price_missing,
    SUM(CASE WHEN Discount_Rate     IS NULL THEN 1 ELSE 0 END) AS Discount_Rate_missing,
    SUM(CASE WHEN Customer_ID     IS NULL THEN 1 ELSE 0 END) AS Customer_ID_missing,
    SUM(CASE WHEN Customer_Age    IS NULL THEN 1 ELSE 0 END) AS Customer_Age_missing,
    SUM(CASE WHEN Delivery_Time_Min  IS NULL THEN 1 ELSE 0 END) AS Delivery_Time_Min_missing,
    SUM(CASE WHEN Delivery_Distance_KM  IS NULL THEN 1 ELSE 0 END) AS Delivery_Distance_KM_missing,
    SUM(CASE WHEN Staff_ID     IS NULL THEN 1 ELSE 0 END) AS Staff_ID_missing,
    SUM(CASE WHEN Temperature_Celsius     IS NULL THEN 1 ELSE 0 END) AS Temperature_Celsius_missing,
    SUM(CASE WHEN Humidity_Percent    IS NULL THEN 1 ELSE 0 END) AS Humidity_Percent_missing,
    SUM(CASE WHEN Store_Rating  IS NULL THEN 1 ELSE 0 END) AS Store_Rating_missing,
    SUM(CASE WHEN Tax_Amount    IS NULL THEN 1 ELSE 0 END) AS Tax_Amount_missing,
    SUM(CASE WHEN Total_Sales  IS NULL THEN 1 ELSE 0 END) AS Total_Sales_missing,
    COUNT(*) AS total_rows
FROM blaban_data;
--Membership_Status,Topping_Type,Customer_Gender,Customer_Age,Store_Rating columns have nulls and missing values ranging from 820:858

-- ---- SECTION 4: Numeric Range Check --------

-- Are values realistic? Spot outliers
SELECT
    MIN(Unit_Price)          AS min_price,    MAX(Unit_Price)          AS max_price,
    MIN(Quantity)            AS min_qty,      MAX(Quantity)            AS max_qty,
    MIN(Discount_Rate)       AS min_disc,     MAX(Discount_Rate)       AS max_disc,
    MIN(Customer_Age)        AS min_age,      MAX(Customer_Age)        AS max_age,
    MIN(Delivery_Time_Min)   AS min_del_time, MAX(Delivery_Time_Min)   AS max_del_time,
    MIN(Delivery_Distance_KM)AS min_dist,     MAX(Delivery_Distance_KM)AS max_dist,
    MIN(Store_Rating)        AS min_rating,   MAX(Store_Rating)        AS max_rating,
    MIN(Total_Sales)         AS min_sales,    MAX(Total_Sales)         AS max_sales
FROM blaban_data;
-- Unit_Price and Customer_Age columns have outliers


-- ---- SECTION 5: Duplicate Check ------------

-- Are Transaction_IDs truly unique?
SELECT Transaction_ID, COUNT(*) AS occurrences
FROM blaban_data
GROUP BY Transaction_ID
HAVING COUNT(*) > 1;
-- No issues

-- ---- SECTION 6: Consistency Check ----------

-- Does Total_Sales match Unit_Price * Quantity * (1 - Discount_Rate) + Tax_Amount?
-- Flags rows where the math doesn't add up (tolerance of 0.01 for rounding)
SELECT Transaction_ID, Unit_Price, Quantity, Discount_Rate, Tax_Amount, Total_Sales,
    ROUND((Unit_Price * Quantity * (1 - Discount_Rate)) + Tax_Amount, 2) AS expected_sales
FROM blaban_data
WHERE ABS(Total_Sales - ROUND((Unit_Price * Quantity * (1 - Discount_Rate)) + Tax_Amount, 2)) > 0.01;
-- Quantity column has negative values creates problems in calculations,we'll try this again after fixing the negative values
