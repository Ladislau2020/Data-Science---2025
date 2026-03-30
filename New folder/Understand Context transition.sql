USE [WideWorldImportersDW]
GO
WITH
acte AS(
SELECT
c.City
, f.Quantity
, SUM(f.quantity) OVER(PARTITION BY c.[city])AS sumx_usingsum
, SUM(f.quantity) OVER(PARTITION BY f.[sale key]) AS sumx_usingcalculateandsum
FROM
[Fact].[Sale] AS f
INNER JOIN [Dimension].[City] AS c ON
f.[City Key] = c.[City Key]
)
SELECT
acte.city
, SUM(acte.quantity) AS FilterContext
, SUM(acte.quantity) AS SUMX_JustColumnReference
, SUM(acte.sumx_usingsum) AS SUMX_UsingSum
, SUM(acte.sumx_usingcalculateandsum) AS
SUMX_UsingSumAndCalculate , COUNT(*) AS noofrows_FactSale
FROM
acte
GROUP BY
acte.city
ORDER BY acte.City ASC