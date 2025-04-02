-- Total Sales Over Time (Monthly)
SELECT 
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    FORMAT(SUM(TotalDue), 'C') AS TotalSales
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Year, Month;

-- Total Sales Over Time (Quarterly)
SELECT 
    YEAR(OrderDate) AS Year,
    DATEPART(QUARTER, OrderDate) AS Quarter,
    FORMAT(SUM(TotalDue), 'C') AS TotalSales
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), DATEPART(QUARTER, OrderDate)
ORDER BY Year, Quarter;

-- Sales by Product Category
SELECT 
    pc.Name AS ProductCategory,
    FORMAT(SUM(sod.LineTotal), 'C') AS TotalSales,
    COUNT(DISTINCT soh.SalesOrderID) AS OrderCount
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY TotalSales DESC;

-- Sales by Product Subcategory (More Detailed Breakdown)
SELECT 
    pc.Name AS ProductCategory,
    ps.Name AS ProductSubcategory,
    FORMAT(SUM(sod.LineTotal), 'C') AS TotalSales
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name, ps.Name
ORDER BY pc.Name, TotalSales DESC;

-- Sales by Region (By Country)
SELECT 
    cr.Name AS CountryRegion,
    FORMAT(SUM(soh.TotalDue), 'C') AS TotalSales,
    COUNT(DISTINCT soh.SalesOrderID) AS OrderCount
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
JOIN Person.CountryRegion cr ON st.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;

-- Sales by Region (More Detailed - By Territory)
SELECT 
    cr.Name AS CountryRegion,
    st.Name AS Territory,
    FORMAT(SUM(soh.TotalDue), 'C') AS TotalSales,
    COUNT(DISTINCT soh.SalesOrderID) AS OrderCount
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
JOIN Person.CountryRegion cr ON st.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name, st.Name
ORDER BY cr.Name, TotalSales DESC;

-- Customer Acquisition Rate (Monthly)
SELECT 
    YEAR(c.ModifiedDate) AS Year, 
    MONTH(c.ModifiedDate) AS Month,
    COUNT(*) AS NewCustomers
FROM Sales.Customer c
GROUP BY YEAR(c.ModifiedDate), MONTH(c.ModifiedDate)
ORDER BY Year, Month;

-- Alternative Customer Acquisition Rate (Based on First Order Date)
WITH CustomerFirstOrder AS (
    SELECT 
        c.CustomerID,
        MIN(soh.OrderDate) AS FirstOrderDate
    FROM Sales.Customer c
    JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
    GROUP BY c.CustomerID
)
SELECT 
    YEAR(FirstOrderDate) AS Year,
    MONTH(FirstOrderDate) AS Month,
    COUNT(*) AS NewCustomers
FROM CustomerFirstOrder
GROUP BY YEAR(FirstOrderDate), MONTH(FirstOrderDate)
ORDER BY Year, Month;

-- Average Order Value (Overall)
SELECT 
    FORMAT(AVG(TotalDue), 'C') AS AvgOrderValue,
    FORMAT(MIN(TotalDue), 'C') AS MinOrderValue,
    FORMAT(MAX(TotalDue), 'C') AS MaxOrderValue
FROM Sales.SalesOrderHeader;

-- Average Order Value (By Year)
SELECT 
    YEAR(OrderDate) AS Year,
    FORMAT(AVG(TotalDue), 'C') AS AvgOrderValue,
    FORMAT(MIN(TotalDue), 'C') AS MinOrderValue,
    FORMAT(MAX(TotalDue), 'C') AS MaxOrderValue,
    COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY Year;

-- Average Order Value (By Customer Type)
SELECT 
    CASE 
        WHEN soh.OnlineOrderFlag = 1 THEN 'Online'
        ELSE 'In-Store'
    END AS OrderType,
    FORMAT(AVG(TotalDue), 'C') AS AvgOrderValue,
    COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader soh
GROUP BY soh.OnlineOrderFlag;