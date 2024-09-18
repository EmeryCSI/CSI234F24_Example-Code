/*Complete the following exercises:

Write a query to retrieve the product ID, name, and list price for all products in the SalesLT.Product table.*/
Select pro.ProductID, pro.Name, pro.ListPrice
FROM SalesLT.Product AS pro

--Create a query to list the sales order ID, order date, and total due for all orders in the SalesLT.SalesOrderHeader table.
SELECT soh.SalesOrderID, soh.OrderDate, soh.TotalDue
FROM SalesLt.SalesOrderHeader AS soh;

--Develop a query to display the customer ID, full name (first name + last name), and email address for all customers, using appropriate column aliases.

--Write a query to display the customer's full name (FirstName + LastName) 
--and the total number of orders they have placed. Include all customers, even if they haven't placed any orders.
SELECT C.FirstName + ' ' + C.LastName AS FullName 
FROM SalesLT.Customer AS C
JOIN SalesLT.SalesOrderHeader AS SOH
ON C.CustomerID = SOH.CustomerID;

--COUNT Gives you total of rows
SELECT COUNT(*) FROM SalesLT.SalesOrderHeader

SELECT COUNT(*) FROM SalesLT.SalesOrderHeader WHERE CustomerID = 29847;
