-- ===================================================
-- PHASE 3: ANALYSIS
-- ===================================================

-- ---- SECTION 1: REVENUE ANALYSIS ---------------

-- Total revenue, orders, and avg order value overall
SELECT
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value,
    ROUND(SUM(Tax_Amount), 2)       AS total_tax,
    ROUND(SUM(Discount_Rate * Unit_Price * Quantity), 2) AS total_discount_given
FROM blaban_data;

-- Revenue by Branch
SELECT
    Branch,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value,
    ROUND(SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER(), 2) AS revenue_pct
FROM blaban_data
GROUP BY Branch
ORDER BY total_revenue DESC;

-- Revenue by Region
SELECT
    Region,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value,
    ROUND(SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER(), 2) AS revenue_pct
FROM blaban_data
GROUP BY Region
ORDER BY total_revenue DESC;

-- Revenue by Product
SELECT
    Product_Name,
    Category,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value,
    ROUND(AVG(Quantity), 1)         AS avg_qty_per_order
FROM blaban_data
GROUP BY Product_Name, Category
ORDER BY total_revenue DESC;

-- Revenue by Category
SELECT
    Category,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value
FROM blaban_data
GROUP BY Category
ORDER BY total_revenue DESC;

-- Revenue by Size
SELECT
    Size,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value
FROM blaban_data
GROUP BY Size
ORDER BY total_revenue DESC;

-- Impact of Discount on Revenue
SELECT
    CASE 
        WHEN Discount_Rate = 0    THEN 'No Discount'
        WHEN Discount_Rate <= 0.05 THEN 'Up to 5%'
        WHEN Discount_Rate <= 0.10 THEN 'Up to 10%'
        ELSE 'Above 10%'
    END AS discount_tier,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value
FROM blaban_data
GROUP BY 
    CASE 
        WHEN Discount_Rate = 0    THEN 'No Discount'
        WHEN Discount_Rate <= 0.05 THEN 'Up to 5%'
        WHEN Discount_Rate <= 0.10 THEN 'Up to 10%'
        ELSE 'Above 10%'
    END
ORDER BY total_revenue DESC;

-- Monthly Revenue Trend
SELECT
    FORMAT(Date_Time, 'yyyy-MM')    AS month,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value
FROM blaban_data
GROUP BY FORMAT(Date_Time, 'yyyy-MM')
ORDER BY month;


-- ---- SECTION 2: CUSTOMER ANALYSIS -------------

-- Revenue by Membership Status
SELECT
    Membership_Status,
    COUNT(*)                        AS total_orders,
    COUNT(DISTINCT Customer_ID)     AS unique_customers,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value
FROM blaban_data
GROUP BY Membership_Status
ORDER BY total_revenue DESC;

-- Revenue by Gender
SELECT
    Customer_Gender,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value
FROM blaban_data
GROUP BY Customer_Gender
ORDER BY total_revenue DESC;

-- Revenue by Age Group
SELECT
    CASE
        WHEN Customer_Age < 18 THEN 'Under 18'
        WHEN Customer_Age <= 25 THEN '18-25'
        WHEN Customer_Age <= 35 THEN '26-35'
        WHEN Customer_Age <= 45 THEN '36-45'
        WHEN Customer_Age <= 60 THEN '46-60'
        ELSE 'Above 60'
    END AS age_group,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value
FROM blaban_data
GROUP BY
    CASE
        WHEN Customer_Age < 18 THEN 'Under 18'
        WHEN Customer_Age <= 25 THEN '18-25'
        WHEN Customer_Age <= 35 THEN '26-35'
        WHEN Customer_Age <= 45 THEN '36-45'
        WHEN Customer_Age <= 60 THEN '46-60'
        ELSE 'Above 60'
    END
ORDER BY total_revenue DESC;

-- Revenue by Payment Method
SELECT
    Payment_Method,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value
FROM blaban_data
GROUP BY Payment_Method
ORDER BY total_revenue DESC;

-- ---- SECTION 3: OPERATIONS ANALYSIS -----------

-- Revenue by Order Source
SELECT
    Order_Source,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value,
    ROUND(AVG(Delivery_Time_Min), 1) AS avg_delivery_time
FROM blaban_data
GROUP BY Order_Source
ORDER BY total_revenue DESC;

-- Peak Hours Analysis
SELECT
    Hour_of_Day,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value
FROM blaban_data
GROUP BY Hour_of_Day
ORDER BY Hour_of_Day;

-- Weekend vs Weekday
SELECT
    CASE WHEN Is_Weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value,
    ROUND(AVG(Delivery_Time_Min), 1) AS avg_delivery_time
FROM blaban_data
GROUP BY Is_Weekend;

-- Delivery Performance by Branch
SELECT
    Branch,
    ROUND(AVG(Delivery_Time_Min), 1)    AS avg_delivery_time,
    MIN(Delivery_Time_Min)              AS fastest_delivery,
    MAX(Delivery_Time_Min)              AS slowest_delivery,
    ROUND(AVG(Delivery_Distance_KM), 2) AS avg_distance
FROM blaban_data
GROUP BY Branch
ORDER BY avg_delivery_time;

-- Store Rating by Branch
SELECT
    Branch,
    ROUND(AVG(Store_Rating), 2)     AS avg_rating,
    COUNT(*)                        AS total_orders
FROM blaban_data
GROUP BY Branch
ORDER BY avg_rating DESC;

-- ---- SECTION 4: EXTERNAL FACTORS ANALYSIS -----

-- Public Holiday vs Normal Day
SELECT
    CASE WHEN Is_Public_Holiday = 1 THEN 'Public Holiday' ELSE 'Normal Day' END AS day_type,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value,
    ROUND(AVG(Delivery_Time_Min), 1) AS avg_delivery_time
FROM blaban_data
GROUP BY Is_Public_Holiday;

-- Weather Impact (Temperature Bands)
SELECT
    CASE
        WHEN Temperature_Celsius < 15 THEN 'Cold (< 15°C)'
        WHEN Temperature_Celsius <= 25 THEN 'Mild (15–25°C)'
        WHEN Temperature_Celsius <= 35 THEN 'Warm (25–35°C)'
        ELSE 'Hot (> 35°C)'
    END AS temp_band,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value
FROM blaban_data
GROUP BY
    CASE
        WHEN Temperature_Celsius < 15 THEN 'Cold (< 15°C)'
        WHEN Temperature_Celsius <= 25 THEN 'Mild (15–25°C)'
        WHEN Temperature_Celsius <= 35 THEN 'Warm (25–35°C)'
        ELSE 'Hot (> 35°C)'
    END
ORDER BY total_revenue DESC;

-- Humidity Impact
SELECT
    CASE
        WHEN Humidity_Percent < 30 THEN 'Low (< 30%)'
        WHEN Humidity_Percent <= 60 THEN 'Moderate (30–60%)'
        ELSE 'High (> 60%)'
    END AS humidity_band,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(Total_Sales), 2)      AS total_revenue,
    ROUND(AVG(Total_Sales), 2)      AS avg_order_value
FROM blaban_data
GROUP BY
    CASE
        WHEN Humidity_Percent < 30 THEN 'Low (< 30%)'
        WHEN Humidity_Percent <= 60 THEN 'Moderate (30–60%)'
        ELSE 'High (> 60%)'
    END
ORDER BY total_revenue DESC;