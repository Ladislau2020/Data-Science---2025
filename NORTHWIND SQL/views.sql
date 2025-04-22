CREATE VIEW "Top 10 Customers by Revenue" AS
(SELECT TOP (10) c.[CompanyName], ROUND(SUM(([UnitPrice] * [Quantity]) - [Discount]), 0) AS price
FROM [dbo].[orders] o
JOIN  [dbo].[customers] c ON o.[CustomerID] = c.[CustomerID]
JOIN [dbo].[order_details] od ON od.OrderID = o.OrderID
GROUP BY c.[CompanyName]
ORDER BY price DESC
);