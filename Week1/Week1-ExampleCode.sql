-- Renton Technical College CSI-234
-- Week 1: Introduction to SQL Querying

-- Make sure we're using the correct database
USE NameOfYourSampleDB;
GO

-- Part 1: Basic SELECT Statements
-- ===============================

-- The SELECT statement is used to query data from a database.
-- Basic syntax:
-- SELECT column1, column2, ... FROM table_name;

-- This query retrieves all columns and rows from the Address table
SELECT * 
FROM SalesLT.Address;

-- This query selects specific columns from the Address table
SELECT AddressID, AddressLine1, City, StateProvince, CountryRegion
FROM SalesLT.Address;

-- This query combines address information into more readable formats using aliases
SELECT 
    AddressID,
    AddressLine1 + ISNULL(', ' + AddressLine2, '') AS FullAddress,
    City + ', ' + StateProvince + ', ' + CountryRegion AS Location
FROM SalesLT.Address;

-- This query retrieves product information and converts the weight from kilograms to pounds
SELECT 
    ProductID,
    Name,
    Weight,
    Size,
    Weight * 2.2 AS WeightInPounds
FROM SalesLT.Product
WHERE Weight IS NOT NULL;

-- This query demonstrates the use of built-in functions for rounding prices and extracting the year from a date
SELECT 
    ProductID,
    Name,
    ListPrice,
    ROUND(ListPrice, 0) AS RoundedPrice,
    YEAR(SellStartDate) AS SellStartYear
FROM SalesLT.Product;

-- Part 2: Filtering and Sorting
-- =============================

-- This query filters products by color (Black) or size (L)
SELECT ProductID, Name, Color, Size
FROM SalesLT.Product
WHERE Color = 'Black' OR Size = 'L';

-- This query finds products with a list price between 1000 and 1500
SELECT ProductID, Name, ListPrice
FROM SalesLT.Product
WHERE ListPrice > 1000 AND ListPrice < 1500;

-- This query retrieves products that are Red, Blue, or Black
SELECT ProductID, Name, Color
FROM SalesLT.Product
WHERE Color IN ('Red', 'Blue', 'Black');

-- This query finds products with a sell start date in the 2005-2006 fiscal year
SELECT ProductID, Name, SellStartDate
FROM SalesLT.Product
WHERE SellStartDate BETWEEN '2005-07-01' AND '2006-06-30';

-- This query finds all products with 'Bike' in their name
SELECT ProductID, Name
FROM SalesLT.Product
WHERE Name LIKE '%Bike%';

-- This query finds products with names like 'Mountain-100', 'Mountain-200', etc.
SELECT ProductID, Name
FROM SalesLT.Product
WHERE Name LIKE 'Mountain-___';

-- This query retrieves products with non-null weights and sorts them by weight in ascending order
SELECT ProductID, Name, Weight
FROM SalesLT.Product
WHERE Weight IS NOT NULL
ORDER BY Weight ASC;

-- This query sorts products by color (ascending) and then by list price (descending)
SELECT ProductID, Name, Color, ListPrice
FROM SalesLT.Product
ORDER BY Color ASC, ListPrice DESC;

-- This query retrieves the top 10 customers sorted by company name
SELECT TOP 10 CustomerID, FirstName, LastName, CompanyName
FROM SalesLT.Customer
ORDER BY CompanyName;

-- This query retrieves the top 5% most expensive products
SELECT TOP 5 PERCENT ProductID, Name, ListPrice
FROM SalesLT.Product
ORDER BY ListPrice DESC;

-- Part 3: JOIN Operations
-- =======================

-- This query joins the Product and ProductCategory tables to show each product with its category
SELECT p.ProductID, p.Name, pc.Name AS CategoryName
FROM SalesLT.Product AS p
INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID;

-- This query retrieves all customers and their addresses (if available)
SELECT c.CustomerID, c.FirstName, c.LastName, a.AddressLine1, a.City
FROM SalesLT.Customer c
LEFT JOIN SalesLT.CustomerAddress ca ON c.CustomerID = ca.CustomerID
LEFT JOIN SalesLT.Address a ON ca.AddressID = a.AddressID;

-- This query shows all products and their product models (if available)
SELECT p.ProductID, p.Name, pm.ThumbNailPhoto
FROM SalesLT.ProductModel pm
RIGHT JOIN SalesLT.Product p ON pm.ProductModelID = p.ProductModelID;

-- This query combines customer, order, and product information to show what products each customer has ordered
SELECT c.CustomerID, c.FirstName, c.LastName, soh.SalesOrderID, soh.OrderDate, p.Name AS ProductName
FROM SalesLT.Customer c
INNER JOIN SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
INNER JOIN SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN SalesLT.Product p ON sod.ProductID = p.ProductID;

-- This query shows all products and their reviews (if any), including products without reviews
SELECT p.ProductID, p.Name, pr.ProductReviewID
FROM SalesLT.Product p
FULL OUTER JOIN SalesLT.ProductReview pr ON p.ProductID = pr.ProductID;

-- Part 4: Aggregate Functions and GROUP BY
-- ========================================

-- This query counts the total number of addresses in the Address table
SELECT COUNT(*) AS TotalAddresses
FROM SalesLT.Address;

-- This query counts the number of unique cities in the Address table
SELECT COUNT(DISTINCT City) AS UniqueCities
FROM SalesLT.Address;

-- This query calculates the total quantity of all products ordered
SELECT SUM(OrderQty) AS TotalQuantityOrdered
FROM SalesLT.SalesOrderDetail;

-- This query calculates the average weight of all products (excluding those with null weight)
SELECT AVG(Weight) AS AverageWeight
FROM SalesLT.Product
WHERE Weight IS NOT NULL;

-- This query finds the dates of the most recent and oldest orders
SELECT 
    MAX(OrderDate) AS MostRecentOrder,
    MIN(OrderDate) AS OldestOrder
FROM SalesLT.SalesOrderHeader;

-- This query counts the number of products in each category, showing only categories with more than 10 products
SELECT ProductCategoryID, COUNT(*) AS ProductCount
FROM SalesLT.Product
GROUP BY ProductCategoryID
HAVING COUNT(*) > 10;

-- This query shows each customer's order count and total spending, for customers who have placed orders
SELECT c.CustomerID, c.FirstName, c.LastName, COUNT(soh.SalesOrderID) AS OrderCount, SUM(soh.TotalDue) AS TotalSpent
FROM SalesLT.Customer c
LEFT JOIN SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING COUNT(soh.SalesOrderID) > 0
ORDER BY TotalSpent DESC;

-- Part 5: Data Modification (INSERT, UPDATE, DELETE)
-- ==================================================

-- This query adds a new product category called 'Vintage Bikes'
INSERT INTO SalesLT.ProductCategory (ParentProductCategoryID, Name)
VALUES (4, 'Vintage Bikes');

-- This query creates a new category based on an existing top-level category
INSERT INTO SalesLT.ProductCategory (ParentProductCategoryID, Name)
SELECT TOP 1 ProductCategoryID, 'New Category ' + Name
FROM SalesLT.ProductCategory
WHERE ParentProductCategoryID IS NULL;

-- This query increases the list price of all 'Vintage Bikes' products by 10%
UPDATE SalesLT.Product
SET ListPrice = ListPrice * 1.10
WHERE ProductCategoryID = (SELECT ProductCategoryID FROM SalesLT.ProductCategory WHERE Name = 'Vintage Bikes');

-- This query removes the 'Vintage Bikes' category from the ProductCategory table
DELETE FROM SalesLT.ProductCategory
WHERE Name = 'Vintage Bikes';

-- Part 6: Subqueries
-- ==================

-- This query finds customers who have placed orders totaling more than $5000
SELECT CustomerID, FirstName, LastName
FROM SalesLT.Customer
WHERE CustomerID IN (SELECT CustomerID FROM SalesLT.SalesOrderHeader WHERE TotalDue > 5000);

-- This query shows product categories that have more than 5 products
SELECT CategoryName, ProductCount
FROM (
    SELECT pc.Name AS CategoryName, COUNT(*) AS ProductCount
    FROM SalesLT.ProductCategory pc
    JOIN SalesLT.Product p ON pc.ProductCategoryID = p.ProductCategoryID
    GROUP BY pc.ProductCategoryID, pc.Name
) AS CategoryStats
WHERE ProductCount > 5;

-- This query finds products that are more expensive than the average price in their category
SELECT p.ProductID, p.Name, p.ListPrice
FROM SalesLT.Product p
WHERE p.ListPrice > (
    SELECT AVG(ListPrice)
    FROM SalesLT.Product
    WHERE ProductCategoryID = p.ProductCategoryID
);

-- This query shows each product's price compared to the overall average price
SELECT 
    ProductID, 
    Name, 
    ListPrice, 
    (SELECT AVG(ListPrice) FROM SalesLT.Product) AS AvgPrice,
    ListPrice - (SELECT AVG(ListPrice) FROM SalesLT.Product) AS PriceDifference
FROM SalesLT.Product;

-- This query finds customers who have placed at least one order over $5000
SELECT CustomerID, FirstName, LastName
FROM SalesLT.Customer c
WHERE EXISTS (
    SELECT 1 
    FROM SalesLT.SalesOrderHeader 
    WHERE CustomerID = c.CustomerID AND TotalDue > 5000
);

-- End of Week 1 SQL Script
