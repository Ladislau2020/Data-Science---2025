
-- 1.	Customer Segmentation: What are the top 10 customers by revenue?

SELECT TOP (10) c.[CompanyName], ROUND(SUM(([UnitPrice] * [Quantity]) - [Discount]), 0) AS price
FROM [dbo].[orders] o
JOIN  [dbo].[customers] c ON o.[CustomerID] = c.[CustomerID]
JOIN [dbo].[order_details] od ON od.OrderID = o.OrderID
GROUP BY c.[CompanyName]
ORDER BY price DESC;

-- 2.	Geographical Insights: Which regions or countries have the highest sales?
SELECT r.RegionDescription,  ROUND(SUM(([UnitPrice] * [Quantity]) - [Discount]), 0) AS price
FROM [dbo].[orders] o 
JOIN [dbo].[employees] e ON o.EmployeeID = e.EmployeeID
JOIN [dbo].[order_details] od ON o.OrderID = od.OrderID
JOIN [dbo].[employee_territories] et ON o.EmployeeID = et.EmployeeID
JOIN [dbo].[territories] t ON et.[TerritoryID] = t.[TerritoryID]
JOIN [dbo].[region] r ON r.RegionID = t.RegionID
GROUP BY r.RegionDescription
ORDER BY price DESC;


-- 3.	Retention Analysis: How many repeat customers do you have versus new customers?
WITH new AS (

SELECT [CustomerID], COUNT([CustomerID]) AS customerCount
 FROM [NORTHWND].[dbo].[orders]
 GROUP BY [CustomerID]
 HAVING COUNT([CustomerID]) < = 3
 ), 
 repeated AS  (
 SELECT [CustomerID], COUNT([CustomerID]) AS customerCount
 FROM [NORTHWND].[dbo].[orders]
 GROUP BY [CustomerID]
 HAVING COUNT([CustomerID]) > 3
 )

 SELECT 'New Customers' AS customerType, 
 COUNT(*) AS TotalCustomers,
 SUM(customerCount) AS TotalOrders,
 AVG(customerCount * 1.0) AS AvgOrdersPerCustomer
 from new
 UNION ALL
 SELECT 'Old Customers' AS CustomerType,
 COUNT(*) AS TotalCustomers,
 SUM(customerCount) AS TotalOrders,
 AVG(customerCount * 1.0) AS AvgOrdersPerCustomer
 from repeated;


 -- Sales and Revenue Analysis

 --4.	Revenue Trends: How has revenue evolved over the years?
 WITH yearly_revenue AS (

SELECT YEAR(o.OrderDate) AS year, ROUND(SUM(([UnitPrice] * [Quantity]) - [Discount]), 0) AS revenue
FROM [dbo].[orders] o
JOIN  [dbo].[customers] c ON o.[CustomerID] = c.[CustomerID]
JOIN [dbo].[order_details] od ON od.OrderID = o.OrderID
GROUP BY YEAR(o.OrderDate)
)
SELECT
	year,
	revenue,
	ROUND(((revenue - LAG(revenue) OVER (ORDER BY year)) * 100.0) / LAG(revenue) OVER (ORDER BY year), 2)
	AS percentage_change
FROM yearly_revenue;

-- 5.	Top Products: What are the top 5 best-selling products?
SELECT TOP (5) p.ProductName, ROUND(SUM((od.[UnitPrice] * [Quantity]) - [Discount]), 0) AS revenue
FROM [dbo].[order_details] od
JOIN  [dbo].[products] p ON p.ProductID = od.ProductID	
GROUP BY p.ProductName
ORDER BY revenue DESC;



--6.	Order Frequency: How frequently do customers place orders on average?
WITH order_frequencies1 AS (
    SELECT 
        CustomerID,
		DATEDIFF(DAY,LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) , OrderDate) AS days_between_orders
    FROM dbo.orders
), order_frequencies AS (
	SELECT 
		CustomerID, AVG(days_between_orders) AS days_between_orders
	FROM order_frequencies1
	GROUP BY CustomerID
)	SELECT 
    CASE 
        WHEN days_between_orders < 7 THEN 'Weekly'
        WHEN days_between_orders BETWEEN 7 AND 30 THEN 'Monthly'
        WHEN days_between_orders > 30 THEN 'Infrequent'
        ELSE 'Unknown'
    END AS FrequencyCategory, COUNT(CustomerID) AS CustomerCount
FROM order_frequencies
WHERE 
days_between_orders IS NOT NULL
GROUP BY 
    CASE 
        WHEN days_between_orders < 7 THEN 'Weekly'
        WHEN days_between_orders BETWEEN 7 AND 30 THEN 'Monthly'
        WHEN days_between_orders > 30 THEN 'Infrequent'
        ELSE 'Unknown'
    END
ORDER BY 
    CustomerCount DESC;

-- 7.	Low Stock Alerts: Which products are running low on stock?
-- How frequently do customers place orders?
WITH order_frequencies AS (
    SELECT 
        CustomerID,
		DATEDIFF(DAY,LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) , OrderDate) AS days_between_orders
    FROM dbo.orders
)SELECT 
    CASE 
        WHEN days_between_orders < 7 THEN 'Weekly'
        WHEN days_between_orders BETWEEN 7 AND 30 THEN 'Monthly'
        WHEN days_between_orders > 30 THEN 'Infrequent'
        ELSE 'Unknown'
    END AS FrequencyCategory, COUNT(CustomerID) AS CustomerCount 
FROM order_frequencies
WHERE 
days_between_orders IS NOT NULL
GROUP BY 
    CASE 
        WHEN days_between_orders < 7 THEN 'Weekly'
        WHEN days_between_orders BETWEEN 7 AND 30 THEN 'Monthly'
        WHEN days_between_orders > 30 THEN 'Infrequent'
        ELSE 'Unknown'
    END
ORDER BY 
    CustomerCount DESC;

-- Days since last Order
SELECT 
    CustomerID,
    MAX(OrderDate) AS LastOrderDate,
    DATEDIFF(DAY, MAX(OrderDate), GETDATE()) AS DaysSinceLastOrder
FROM 
    dbo.orders
GROUP BY 
    CustomerID
ORDER BY 
    DaysSinceLastOrder DESC; -- Longest inactive customers first


-- AVERAGE DAYS BETWEEN ORDERS
WITH order_differences AS (
    SELECT 
        CustomerID,
        DATEDIFF(DAY, LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate), OrderDate) AS days_between_orders
    FROM 
        dbo.orders
)
SELECT 
    CustomerID,
    AVG(days_between_orders * 1.0) AS avg_days_between_orders
FROM 
    order_differences
WHERE 
    days_between_orders IS NOT NULL -- Exclude the first order
GROUP BY 
    CustomerID
ORDER BY 
    avg_days_between_orders;


-- Inventory Management
-- 7.	Low Stock Alerts: Which products are running low on stock?
SELECT 
       [ProductName]
      ,[UnitsInStock]
      ,[UnitsOnOrder]
      ,[ReorderLevel]
  FROM [NORTHWND].[dbo].[products]
  WHERE [Discontinued] = 0 AND ([UnitsInStock] < [ReorderLevel]);


  -- 8.	Supplier Performance: Which suppliers deliver the most products, and how timely are they?
  SELECT 
    s.SupplierID,
    s.CompanyName,
    COUNT(o.OrderID) AS TotalOrders,
    AVG(DATEDIFF(DAY, o.OrderDate, o.ShippedDate)) AS AvgDeliveryTime,
    SUM(p.UnitsInStock + p.UnitsOnOrder) AS TotalProductQty
FROM 
    [dbo].Suppliers s
JOIN 
    [dbo].Products p ON s.SupplierID = p.SupplierID
JOIN 
    [dbo].order_details od ON od.ProductID = p.ProductID
JOIN 
    [dbo].Orders o ON o.OrderID = od.OrderID
WHERE 
    p.Discontinued = 0
GROUP BY 
    s.SupplierID, s.CompanyName
ORDER BY 
    TotalProductQty DESC, AvgDeliveryTime ASC;


-- Employee Performance
-- 10.	Sales by Employee: Which employees are generating the most sales?
SELECT e.FirstName
	  ,FORMAT(ROUND(SUM((([UnitPrice] * [Quantity]) - [Discount])), 2), 'C', 'en-US') AS total_sold
  FROM [NORTHWND].[dbo].[orders] o
  JOIN [dbo].[employees] e ON o.EmployeeID = e.EmployeeID
  JOIN [dbo].[order_details] od ON o.OrderID = od.OrderID
  GROUP BY e.FirstName;

-- 11.	Order Processing Times: How long does it take employees to process orders on average?
SELECT 
	e.[FirstName],
	AVG(DATEDIFF(DAY, OrderDate, ShippedDate)) AS AvgDeliveryTimeInDays
FROM [dbo].Orders o
JOIN [dbo].[employees] e ON e.EmployeeID = o.EmployeeID
GROUP BY e.[FirstName];

-- 12.	Performance Trends: How has employee performance changed over the years?
SELECT 
	 YEAR(o.OrderDate) year_
	,MONTH(o.OrderDate) month_
	,COUNT(*) num_sales
	,FORMAT(ROUND(SUM((([UnitPrice] * [Quantity]) - [Discount])), 2), 'C', 'en-us') total_sales
FROM [NORTHWND].[dbo].[orders] o
JOIN [dbo].[order_details] od ON o.OrderID = od.OrderID
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY YEAR(OrderDate), MONTH(OrderDate);


-- option 2
SELECT 
	YEAR(o.OrderDate) year_
	,e.[FirstName]
	,COUNT(*) num_sales
	,FORMAT(ROUND(SUM((([UnitPrice] * [Quantity]) - [Discount])), 2), 'C', 'en-us') total_sales
FROM [NORTHWND].[dbo].[orders] o
JOIN [dbo].[order_details] od ON o.OrderID = od.OrderID
JOIN [dbo].[employees] e ON e.EmployeeID = o.EmployeeID
GROUP BY YEAR(OrderDate), e.[FirstName]
ORDER BY YEAR(OrderDate), total_sales DESC;


-- Operational Efficiency

-- 13.	Shipping Performance: Which shipping methods are the fastest and most cost-effective?
SELECT [CompanyName]
		, SUM([Freight]) AS cost
       ,AVG(DATEDIFF(DAY, OrderDate, ShippedDate)) AS AvgDeliveryTimeInDays
  FROM [NORTHWND].[dbo].[orders] o
    JOIN [NORTHWND].[dbo].[shippers] s ON o.ShipVia = s.ShipperID
  GROUP BY [CompanyName]
  ORDER BY cost , AvgDeliveryTimeInDays;
  -- According to this query, the Federal shipping is the fastest shipping method
  -- But, the Speedy Express is the most cost effective, therefore the most efficient.


  -- 14.	Order Fulfillment Rate: What percentage of orders are fulfilled on time?

  WITH OrdersStats AS (
	SELECT 
		SUM(CASE WHEN [ShippedDate] <= [RequiredDate] THEN 1 ELSE 0 END) AS on_time_orders,
		SUM(CASE WHEN [ShippedDate] > [RequiredDate] THEN 1 ELSE 0 END) AS out_of_time_orders,
		COUNT(*) AS total_orders
	FROM [dbo].[orders]
)
SELECT 'on_time_orders' AS orders,
	   on_time_orders AS number_of_orders,
	   CAST(on_time_orders * 100.0 / total_orders AS DECIMAL(5,2)) AS percentage
FROM OrdersStats
UNION ALL
SELECT 'out_of_time_orders',
	   out_of_time_orders,
	   CAST(out_of_time_orders * 100.0 / total_orders AS DECIMAL(5,2))
FROM OrdersStats;

-- We can see that most orders are placing on time.

-- 16.	Seasonal Patterns: Are there seasonal trends in sales?

SELECT 
	YEAR([OrderDate]) year_
	,MONTH([OrderDate]) month_
	,COUNT(*) total_orders
FROM [dbo].[orders]
GROUP BY YEAR([OrderDate]), MONTH([OrderDate])
ORDER BY YEAR([OrderDate]), MONTH([OrderDate]);


-- 17.	Cross-Sell Opportunities: Which products are frequently bought together?

SELECT 
    o1.productID AS product_A,
    o2.productID AS product_B,
    COUNT(*) AS times_bought_together
FROM [dbo].[order_details] o1
JOIN [dbo].[order_details] o2 
    ON o1.orderID = o2.orderID
   AND o1.productID < o2.productID  -- avoids duplicates and self-pairs
GROUP BY o1.productID, o2.productID
ORDER BY times_bought_together DESC;


-- 18.	Predictive Analytics: Can you predict future sales for the next quarter based on historical data?
WITH QuarterlySales AS (
    SELECT 
        DATEPART(YEAR, [OrderDate]) AS SalesYear,
        DATEPART(QUARTER, [OrderDate]) AS SalesQuarter,
        CONCAT(DATEPART(YEAR, [OrderDate]), 'Q', DATEPART(QUARTER, [OrderDate])) AS YearQuarter,
        COUNT(*) AS TotalSales
    FROM [dbo].[orders]
    GROUP BY DATEPART(YEAR, [OrderDate]), DATEPART(QUARTER, [OrderDate])
),
IndexedSales AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY SalesYear, SalesQuarter) AS t
    FROM QuarterlySales
),
statss AS (
    SELECT 
        COUNT(*) AS n,
        SUM(t) AS sum_t,
        SUM(TotalSales) AS sum_y,
        SUM(t * TotalSales) AS sum_ty,
        SUM(t * t) AS sum_t2
    FROM IndexedSales
),
LinearModel AS (
    SELECT
        CAST((n * sum_ty - sum_t * sum_y) AS FLOAT) / NULLIF((n * sum_t2 - sum_t * sum_t), 0) AS slope,
        CAST((sum_y * sum_t2 - sum_t * sum_ty) AS FLOAT) / NULLIF((n * sum_t2 - sum_t * sum_t), 0) AS intercept,
        n + 1 AS next_t
    FROM statss
)
SELECT 
    slope * next_t + intercept AS PredictedSalesNextQuarter
FROM LinearModel;

-- This query uses the liner regression formula   ==>    y = mx + b

