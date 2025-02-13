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
    TransactionDate = COALESCE(TransactionDate, '2000-01-01'),
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
SELECT ProductName, count(Quantity) AS Quantity_sold 
FROM sales
GROUP BY ProductName 
ORDER BY quantity_sold DESC 
LIMIT 5;


-- 
SELECT  
    region, city,
    SUM(TransactionAmount) AS total_sales,
    DENSE_RANK() OVER (PARTITION BY region ORDER BY SUM(TransactionAmount) DESC) AS sales_rank
FROM sales
GROUP BY region,city
ORDER BY region, sales_rank;

