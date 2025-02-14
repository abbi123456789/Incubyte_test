CREATE TABLE IF NOT EXISTS sales (
        TransactionID int Primary key,
        CustomerID Numeric,
        TransactionDate Timestamp,
        TransactionAmount numeric,
        PaymentMethod Text,
        Quantity Numeric,
        DiscountPercent Numeric,
        City Text,
        StoreType Text,
        CustomerAge Numeric,
        CustomerGender Text,
        LoyaltyPoints Numeric,
        ProductName Text,
        Region Text,
        Returned Text,
        FeedbackScore Numeric,
        ShippingCost Numeric,	
        DeliveryTimeDays Numeric,
        IsPromotional Text)

COPY sales FROM 'D:\Incubyte_copy\Incubyte_test.csv' DELIMITER ',' CSV HEADER;

select * from sales 

-- checking Nulls
SELECT 
    COUNT(*) AS total_rows,
    COUNT(TransactionID) AS non_null_TransactionID,
    COUNT(CustomerID) AS non_null_CustomerID,
    COUNT(TransactionDate) AS non_null_TransactionDate,
    COUNT(TransactionAmount) AS non_null_TransactionAmount,
    COUNT(PaymentMethod) AS non_null_PaymentMethod,
    COUNT(Quantity) AS non_null_Quantity,
    COUNT(DiscountPercent) AS non_null_DiscountPercent,
    COUNT(City) AS non_null_City,
    COUNT(StoreType) AS non_null_StoreType,
    COUNT(CustomerAge) AS non_null_CustomerAge,
    COUNT(CustomerGender) AS non_null_CustomerGender,
    COUNT(LoyaltyPoints) AS non_null_LoyaltyPoints,
    COUNT(ProductName) AS non_null_ProductName,
    COUNT(Region) AS non_null_Region,
    COUNT(Returned) AS non_null_Returned,
    COUNT(FeedbackScore) AS non_null_FeedbackScore,
    COUNT(ShippingCost) AS non_null_ShippingCost,
    COUNT(DeliveryTimeDays) AS non_null_DeliveryTimeDays,
    COUNT(IsPromotional) AS non_null_IsPromotional
FROM sales;

/* I found Null values in 
	1.CustomerID
	2.TransactionDate
	3.PaymentMethod
	4.StoreType
	5.CustomerAge
	6.CustomerGender
	7.ProductName
	8.Region*/


-- Updating nulls with Default values
UPDATE sales
SET 
    CustomerID = COALESCE(CustomerID, 0),
    TransactionDate = COALESCE(TransactionDate, '2000-01-01'), -- Assuming 2000-01-01 this one as default instead of Null values
    TransactionAmount = COALESCE(TransactionAmount, 0),
    PaymentMethod = COALESCE(PaymentMethod, 'Unknown'),
    Quantity = COALESCE(Quantity, 0),
    DiscountPercent = COALESCE(DiscountPercent, 0),
    City = COALESCE(City, 'Unknown'),
    StoreType = COALESCE(StoreType, 'Unknown'),
    CustomerAge = COALESCE(CustomerAge, 67), -- Average age as default
    CustomerGender = COALESCE(CustomerGender, 'Unknown'),
    LoyaltyPoints = COALESCE(LoyaltyPoints, 0),
    ProductName = COALESCE(ProductName, 'Unknown'),
    Region = COALESCE(Region, 'Unknown'),
    Returned = COALESCE(Returned, 'Unknown'),
    FeedbackScore = COALESCE(FeedbackScore, 3),  -- Taking the Avg feedback 3 in case of null
    ShippingCost = COALESCE(ShippingCost, 0),
    DeliveryTimeDays = COALESCE(DeliveryTimeDays, 5), -- Taking Avg days 5 in case of null
    IsPromotional = COALESCE(IsPromotional, 'Unknown');
	
-- After Updating i getting same count as original

-- Mapping city and their Respective Region
UPDATE sales
SET region = CASE 
    WHEN city IN ('Ahmedabad', 'Mumbai', 'Pune') THEN 'West'
    WHEN city IN ('Bangalore', 'Chennai', 'Hyderabad') THEN 'South'
    WHEN city IN ('Delhi', 'Jaipur', 'Lucknow') THEN 'North'
    WHEN city = 'Kolkata' THEN 'East'
    ELSE 'Unknown'
END;


--Total Sales & Average Order Value
SELECT 
    SUM(TransactionAmount) AS total_sales, 
    AVG(TransactionAmount) AS avg_order_value 
FROM sales;

-- Region wise sales Amount
select region, SUM(TransactionAmount) AS total_sales
from sales
Group by Region
order by total_sales Desc;

--Top 5 sold products
SELECT ProductName, sum(Quantity) AS Quantity_sold 
FROM sales
GROUP BY ProductName 
ORDER BY quantity_sold DESC 
limit 5;



-- Region and city wise drilldown Sales

SELECT  
    region, city,
    SUM(TransactionAmount) AS total_sales,
    DENSE_RANK() OVER (PARTITION BY region ORDER BY SUM(TransactionAmount) DESC) AS sales_rank
FROM sales
GROUP BY region,city
ORDER BY region, sales_rank;

-- Top 1 Region wise cities with sale
with cte1 as (
SELECT  
    region, city,
    SUM(TransactionAmount) AS total_sales,
    DENSE_RANK() OVER (PARTITION BY region ORDER BY SUM(TransactionAmount) Desc) AS sales_rank
FROM sales
GROUP BY region,city
ORDER BY region, sales_rank)
select * from cte1
where sales_rank=1;

-- Bottom 1 Region wise cities with sale
with cte2 as (
SELECT  
    region, city,
    SUM(TransactionAmount) AS total_sales,
    DENSE_RANK() OVER (PARTITION BY region ORDER BY SUM(TransactionAmount) Asc) AS sales_rank
FROM sales
GROUP BY region,city
ORDER BY region, sales_rank)
select * from cte2
where sales_rank=1;

------Time analysis----
SELECT 
    MIN(TransactionDate) AS first_transaction, 
    MAX(TransactionDate) AS last_transaction
FROM sales;

--Date wise high no of transactions
SELECT 
    TransactionDate::Date AS transaction_day, 
    COUNT(TransactionID) AS No_of_transactions, 
    SUM(TransactionAmount) AS total_sales
FROM sales
GROUP BY transaction_day
ORDER BY No_of_transactions desc;

--Year,month wise transactions and their sales
SELECT    
    EXTRACT(YEAR FROM TransactionDate) AS year,  
    EXTRACT(MONTH FROM TransactionDate) AS month,  
    COUNT(TransactionID) AS total_transactions,  
    SUM(TransactionAmount) AS total_sales  
FROM sales  
GROUP BY year, month  
ORDER BY total_transactions DESC;

--Day wise no of transactions and sales
select 
	extract(day from TransactionDate) AS Day,
	count(TransactionID) as No_of_transactions,
	SUM(TransactionAmount) AS total_sales  
from sales
group by day
order by No_of_transactions desc;


--Discount Impact on total orders and their respective avg sales
SELECT DiscountPercent, COUNT(*) AS total_orders, 
       AVG(TransactionAmount) AS avg_sales 
FROM sales 
GROUP BY DiscountPercent 
ORDER BY Total_orders asc;

--Customer information like 
SELECT CustomerGender,
	Ceil(AVG(CustomerAge)) AS avg_age,
	COUNT(*) AS total_customers ,
	sum(Transactionamount) as total_sales
FROM sales
GROUP BY CustomerGender
order by total_customers desc;

--Delivery days Analysis
SELECT DeliveryTimeDays, COUNT(*) AS total_orders, 
       Round(AVG(ShippingCost),2) AS avg_shipping_cost 
FROM sales
GROUP BY DeliveryTimeDays 
ORDER BY total_orders desc;

-----feedback and Loyalcusomer Analysis----
SELECT 
    FeedbackScore, 
    COUNT(TransactionID) AS transaction_count,
	Round(Avg(TransactionAmount),2) as Avg_amount_spent
FROM sales
GROUP BY FeedbackScore
ORDER BY transaction_count desc;

select avg(LoyaltyPoints), min(LoyaltyPoints), max(LoyaltyPoints) from sales

SELECT 
    city,
    COUNT(*) AS total_ReturnCount
FROM sales
where Returned='Yes'
GROUP BY  city
ORDER BY total_ReturnCount desc;

Select feedbackscore, sum(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) AS total_returns
from sales
group by feedbackscore
order by total_returns desc;

--customer loyalty and their average spent
SELECT 
    CASE 
        WHEN LoyaltyPoints < 1000 THEN 'Low Loyalty (0-999)'
        WHEN LoyaltyPoints BETWEEN 1000 AND 5000 THEN 'Medium Loyalty (1000-4999)'
        ELSE 'High Loyalty (5000+)'
    END AS loyalty_category, 
    Round(AVG(TransactionAmount),2) AS avg_spend_per_transaction
FROM sales
GROUP BY loyalty_category
ORDER BY avg_spend_per_transaction DESC;










