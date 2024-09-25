--Aggregate Function
--Aggregate functions are used to perform calculations on a set of values(rows)
--compress those rows into a single value
--1. Counts the numbers of rows
SELECT COUNT(*)
FROM SalesLT.Product;

--2. Sum: Calculats the total of all of the a given numeric column
SELECT SUM(ListPrice) AS TotalPrice
FROM SalesLT.Product

--You cannot use where with AGG Function
--WHERE Color = 'Red';
--Group BY 
SELECT Color, SUM(ListPrice) AS TotalPrice
FROM SalesLT.Product
GROUP By Color;

--HAVING is a lot like WHERE but it is for AGG with a GROUPBY
SELECT Color, SUM(ListPrice) AS TotalPrice
FROM SalesLT.Product
GROUP By Color
HAVING SUM(ListPrice) > 20000;

--AVG() Use on a numeric column to get the AVG
SELECT AVG(Weight) AS AvgWeight
FROM SalesLT.Product;

--(MIN) (MAX)
SELECT Color, MIN(ListPrice) AS CHEAP, MAX(ListPrice) AS EXPENSIVE
FROM SalesLT.Product
GROUP By Color
HAVING SUM(ListPrice) > 20000;

-- SubQueries
-- The innerquery results in a result set(table) that you can run an outer query on
-- Start with the inner query and make sure you got what you were expecting
-- Lets pretend we want to get all of the products whose price is above average
SELECT ProductId, Name, ListPrice
FROM SalesLT.Product
WHERE ListPrice >
(SELECT AVG(ListPrice)
FROM SalesLT.Product); --This is just some number

-- Lets get all customers who have placed orders
-- Join and subqueries can do similar operations
-- If you only need to show data from one table use a subquery
-- If you need data from more than one use a join
SELECT CustomerId, FirstName, LastName
FROM SalesLT.Customer AS C
WHERE EXISTS (
	SELECT 1
	FROM SalesLT.SalesOrderHeader AS SOH
	WHERE C.CustomerID = SOH.CustomerID
);
-- If you want some practice see if you can write equiv Join

-- IN check to see if a value matches a collection
-- Lets pull all of the products that have been ordered
SELECT ProductID, Name
FROM SalesLT.Product
WHERE ProductID IN 
(SELECT DISTINCT ProductID FROM SalesLT.SalesOrderDetail);

-- LETS talk about INSERT UPDATE DELETE
SELECT * FROM SalesLt.Customer;
-- INSERT INTO SCHEMA.Table (ROWS) VALUES (VALUES TO INSERT)
-- Must supply all required columns
INSERT INTO SalesLT.Customer (FirstName, LastName, CompanyName, EmailAddress)
VALUES('JOHN', 'DOE', '123 Company', 'none@none.com');

-- UPDATE Changes a value
-- UPDATE, SET
-- Before you RUN UPDATE OR DELETE! Always run a select first
-- ALWAYS SELECT BEFORE YOU DO
UPDATE SalesLT.Customer
SET CompanyName = 'Costco'
WHERE LastName = 'Gee' AND FirstName = 'Josh';

-- DELETE FROM
-- SELECT FIRST THEN DELETE
-- DELETE Schema.Table WHERE SomeCondition

-- Transaction?
--This will not work
DELETE FROM SalesLT.ProductCategory WHERE ProductCategoryID = 18;
-- A Transaction is a sequence of one or more Statements that might fail. They are treated
-- as one operation. The whole operation either succeeds or fails

BEGIN TRANSACTION;
--We want to create a new product category
INSERT INTO SalesLT.ProductCategory(Name) VALUES ('NewCategory')

--Only if this is successful create the new product
INSERT INTO SalesLT.Product(Name) VALUES ('Iphone');


-- CHECK FOR ERROR
-- If there is no errors
IF @@ERROR = 0
BEGIN
	--COMMIT, If everything was successful SAVE CHANGES
	PRINT 'Transaction Failed'
	COMMIT TRANSACTION;
END
-- If there are errors
ELSE
BEGIN
	PRINT 'Transaction Failed'
	ROLLBACK TRANSACTION
END

