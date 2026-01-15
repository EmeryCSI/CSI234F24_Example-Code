-- This tutorial covers four key concepts in SQL:
-- 1. Functions
-- 2. Stored Procedures
-- 3. Indexing
-- 4. Schema

-- Each section includes detailed explanations and multiple examples to help
-- beginners understand these concepts thoroughly.

-- =============================================
-- Understanding Batches and the GO Statement
-- =============================================

-- What is a Batch?
-- A batch in SQL Server is a group of one or more T-SQL statements sent to the server 
-- for execution as a single unit. When you send T-SQL statements to SQL Server, the 
-- entire set of statements is compiled into a single execution plan.

-- Why are Batches Important?
-- 1. Execution: SQL Server executes all statements in a batch before returning any results.
-- 2. Variable Scope: Variables declared in a batch are only accessible within that batch.
-- 3. Error Handling: If an error occurs during batch execution, the remainder of the batch might not execute.

-- What is the GO Statement?
-- GO is not a T-SQL statement; it's a command recognized by SQL Server tools like 
-- SQL Server Management Studio (SSMS) and sqlcmd. It signals the end of a batch 
-- to the SQL Server utilities.

-- Why Do We Need GO?
-- 1. Separating Statements: Some T-SQL statements must be the only statement in a batch.
--    Examples include CREATE FUNCTION, ALTER FUNCTION, CREATE PROCEDURE, CREATE TRIGGER.
-- 2. Controlling Execution: GO allows you to execute a batch of statements before moving to the next batch.
-- 3. Resetting Environment: Some settings are batch-scoped. GO helps reset these between batches.
-- 4. Improved Error Handling: By separating code into smaller batches, you can isolate errors more effectively.

-- Example of Using GO
-- Let's create a function to demonstrate the use of GO:

-- This GO ends any previous batch
GO

-- This CREATE FUNCTION statement must be the only one in its batch
CREATE OR ALTER FUNCTION SalesLT.CalculateOrderTotal
(
--Parameters taken in
    @OrderID INT
)
RETURNS MONEY
AS
BEGIN
    DECLARE @Total MONEY;
    
    SELECT @Total = SUM(UnitPrice * OrderQty * (1 - UnitPriceDiscount))
    FROM SalesLT.SalesOrderDetail
    WHERE SalesOrderID = @OrderID;
    
    RETURN ISNULL(@Total, 0);
END
GO

-- Now we can use the function in a new batch
SELECT 
    SalesOrderID,
    SalesLT.CalculateOrderTotal(SalesOrderID) AS OrderTotal
FROM 
    SalesLT.SalesOrderHeader
WHERE 
    SalesOrderID IN (71774, 71776);  -- Example order IDs
GO

-- =============================================
-- 1. Functions
-- =============================================

-- Functions in SQL are reusable code blocks that return a value.
-- They can be used in SELECT statements, WHERE clauses, and other SQL constructs.
-- There are two main types of functions:
--   a) Scalar functions: Return a single value
--   b) Table-valued functions: Return a table

-- 1.1 Scalar Function Example
-- This function calculates the total price of a product with a discount

GO
CREATE OR ALTER FUNCTION dbo.CalculateTotalPrice
(
    @UnitPrice DECIMAL(19,4),
    @Quantity INT,
    @DiscountPercent DECIMAL(4,2)
)
RETURNS DECIMAL(19,4)
AS
BEGIN
    -- Declare a variable to store the result
    DECLARE @TotalPrice DECIMAL(19,4);
    
    -- Calculate the total price:
    -- Multiply unit price by quantity, then subtract the discount
    SET @TotalPrice = @UnitPrice * @Quantity * (1 - @DiscountPercent / 100);
    
    -- Return the calculated total price
    RETURN @TotalPrice;
END;
GO

-- Using the scalar function in a query
-- This query retrieves products from category 6 and calculates the total price for 5 items with a 10% discount
SELECT 
    ProductID,
    Name,
    ListPrice,
    dbo.CalculateTotalPrice(ListPrice, 5, 10) AS TotalPriceFor5Items
FROM 
    SalesLT.Product
WHERE 
    ProductCategoryID = 6;

-- 1.2 Table-Valued Function Example
-- This function returns a table of products within a specified price range

GO
CREATE OR ALTER FUNCTION dbo.GetProductsInPriceRange
(
    @MinPrice DECIMAL(19,4),
    @MaxPrice DECIMAL(19,4)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        ProductID,
        Name,
        ListPrice,
        ProductCategoryID
    FROM 
        SalesLT.Product
    WHERE 
        ListPrice BETWEEN @MinPrice AND @MaxPrice
);
GO

-- Using the table-valued function in a query
-- This query retrieves products priced between $1000 and $1500
SELECT 
    p.ProductID,
    p.Name,
    p.ListPrice,
    c.Name AS CategoryName
FROM 
    dbo.GetProductsInPriceRange(1000, 1500) p
JOIN 
    SalesLT.ProductCategory c ON p.ProductCategoryID = c.ProductCategoryID;

-- =============================================
-- 2. Stored Procedures
-- =============================================

-- Stored procedures are precompiled sets of SQL statements that can be executed multiple times.
-- They can accept parameters, perform complex operations, and return results.
-- Benefits include improved performance, code reusability, and better security.

-- 2.1 Basic Stored Procedure Example
-- This procedure retrieves product details by category

GO
CREATE OR ALTER PROCEDURE dbo.GetProductsByCategory
    @CategoryID INT
AS
BEGIN
    SELECT 
        p.ProductID,
        p.Name AS ProductName,
        p.ListPrice,
        c.Name AS CategoryName
    FROM 
        SalesLT.Product p
    INNER JOIN 
        SalesLT.ProductCategory c ON p.ProductCategoryID = c.ProductCategoryID
    WHERE 
        c.ProductCategoryID = @CategoryID;
END;
GO

-- Executing the stored procedure
EXEC dbo.GetProductsByCategory @CategoryID = 6;

-- 2.2 Advanced Stored Procedure Example
-- This procedure inserts a new customer and returns the new CustomerID

GO
CREATE OR ALTER PROCEDURE dbo.InsertCustomer
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @CompanyName NVARCHAR(128),
    @EmailAddress NVARCHAR(50),
    @NewCustomerID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Insert the new customer
    INSERT INTO SalesLT.Customer 
        (FirstName, LastName, CompanyName, EmailAddress)
    VALUES 
        (@FirstName, @LastName, @CompanyName, @EmailAddress);
    
    -- Get the new CustomerID and set it to the output parameter
    SET @NewCustomerID = SCOPE_IDENTITY();
    
    -- Return the number of affected rows
    RETURN @@ROWCOUNT;
END;
GO

-- Executing the advanced stored procedure
DECLARE @NewID INT;
DECLARE @RowsAffected INT;

EXEC @RowsAffected = dbo.InsertCustomer 
    @FirstName = 'John',
    @LastName = 'Doe',
    @CompanyName = 'ABC Corp',
    @EmailAddress = 'john.doe@example.com',
    @NewCustomerID = @NewID OUTPUT;

-- Display the results
PRINT 'New CustomerID: ' + CAST(@NewID AS NVARCHAR(10));
PRINT 'Rows Affected: ' + CAST(@RowsAffected AS NVARCHAR(10));

-- =============================================
-- Contrast: Functions vs Stored Procedures
-- =============================================

-- While both functions and stored procedures are reusable code blocks, they have some key differences:

-- 1. Return Values:
--    - Functions: Must return a value (scalar or table).
--    - Stored Procedures: Can return multiple result sets and output parameters, but not required.

-- 2. Usage:
--    - Functions: Can be used in SELECT, WHERE, and HAVING clauses.
--    - Stored Procedures: Typically called using EXEC or EXECUTE statement.

-- 3. Transactions:
--    - Functions: Cannot perform transactions or make permanent database changes.
--    - Stored Procedures: Can contain transactions and make permanent changes.

-- 4. Performance:
--    - Functions: Generally better for computational tasks and returning single values.
--    - Stored Procedures: Better for complex operations involving multiple statements.

-- 5. Security:
--    - Functions: Can be used to implement row-level security.
--    - Stored Procedures: Offer more granular control over user permissions.

-- 6. Error Handling:
--    - Functions: Limited error handling capabilities.
--    - Stored Procedures: Can use TRY...CATCH blocks for robust error handling.

-- Choose functions when you need to encapsulate logic for use within queries.
-- Use stored procedures for more complex operations or when you need to perform actions on the database.

-- =============================================
-- 3. Indexing
-- =============================================

-- Indexes are used to speed up data retrieval operations on database tables.
-- They work similarly to an index in a book, allowing quick lookups of data.
-- While indexes improve query performance, they can slow down data modification operations.

-- 3.1 Creating a Non-Clustered Index
-- This index will improve performance of queries that search or sort by LastName

GO
CREATE NONCLUSTERED INDEX IX_Customer_LastName
ON SalesLT.Customer (LastName);
GO

-- Query that benefits from the index
-- This query will use the index to quickly find customers with last names starting with 'S'
SELECT 
    CustomerID,
    FirstName,
    LastName,
    CompanyName
FROM 
    SalesLT.Customer
WHERE 
    LastName LIKE 'S%';

-- 3.2 Creating a Clustered Index
-- Note: A table can have only one clustered index
-- Typically, the primary key of a table is automatically a clustered index

-- Let's create a new table for demonstration
GO
CREATE TABLE dbo.Orders
(
    OrderID INT IDENTITY(1,1),
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(19,4)
);
GO

-- Create a clustered index on the OrderDate column
CREATE CLUSTERED INDEX CIX_Orders_OrderDate
ON dbo.Orders (OrderDate);
GO

-- This query will benefit from the clustered index
SELECT 
    OrderID,
    CustomerID,
    TotalAmount
FROM 
    dbo.Orders
WHERE 
    OrderDate BETWEEN '2024-01-01' AND '2024-03-31';

-- 3.3 Creating a Composite Index
-- A composite index is an index on multiple columns
-- This type of index is useful for queries that frequently filter or sort by these columns together

GO
CREATE NONCLUSTERED INDEX IX_Orders_CustomerID_OrderDate
ON dbo.Orders (CustomerID, OrderDate);
GO

-- This query will benefit from the composite index
SELECT 
    OrderID,
    OrderDate,
    TotalAmount
FROM 
    dbo.Orders
WHERE 
    CustomerID = 1001
    AND OrderDate BETWEEN '2024-01-01' AND '2024-03-31';

-- Explanation of Composite Index:
-- 1. A composite index is created on multiple columns (in this case, CustomerID and OrderDate).
-- 2. The order of columns in the index is important. Here, CustomerID is the first column, followed by OrderDate.
-- 3. This index will be most effective for queries that filter on CustomerID, or on CustomerID and OrderDate together.
-- 4. It can also help in queries that filter only on CustomerID, due to the leftmost prefix principle.
-- 5. However, it won't be as effective for queries that only filter on OrderDate without CustomerID.

-- Benefits of this composite index:
-- - Improves performance for queries filtering on both CustomerID and OrderDate.
-- - Can also improve performance for queries filtering only on CustomerID.
-- - Supports efficient sorting on CustomerID, or on CustomerID and then OrderDate.

-- Considerations:
-- - Increases storage space and can slow down INSERT, UPDATE, and DELETE operations.
-- - Should be created based on the most common query patterns in your application.
-- - The order of columns should typically match the order in which they appear in WHERE clauses and ORDER BY clauses.

-- In practice, you would choose between clustered, non-clustered, and composite indexes
-- based on your specific query patterns and performance requirements.

-- =============================================
-- 4. Schema
-- =============================================

-- A schema is a logical container for database objects like tables, views, and stored procedures.
-- It helps in organizing and managing database objects, and provides a layer of security.

-- 4.1 Creating a new schema
GO
CREATE SCHEMA Marketing;
GO

-- 4.2 Creating a table in the new schema
CREATE TABLE Marketing.Campaigns
(
    CampaignID INT PRIMARY KEY IDENTITY(1,1),
    CampaignName NVARCHAR(50),
    StartDate DATE,
    EndDate DATE,
    Budget DECIMAL(19,4)
);
GO

-- 4.3 Inserting data into the new table
INSERT INTO Marketing.Campaigns (CampaignName, StartDate, EndDate, Budget)
VALUES 
    ('Summer Sale', '2024-06-01', '2024-08-31', 50000.00),
    ('Back to School', '2024-08-15', '2024-09-15', 30000.00),
    ('Holiday Special', '2024-12-01', '2024-12-31', 75000.00);
GO

-- 4.4 Querying data from the new table
SELECT * FROM Marketing.Campaigns;
GO

-- 4.5 Creating a view in the Marketing schema
CREATE VIEW Marketing.ActiveCampaigns
AS
SELECT 
    CampaignID,
    CampaignName,
    StartDate,
    EndDate,
    Budget
FROM 
    Marketing.Campaigns
WHERE 
    GETDATE() BETWEEN StartDate AND EndDate;
GO

-- Querying the view
SELECT * FROM Marketing.ActiveCampaigns;
GO

-- 4.6 Demonstrating schema security
-- Create a new user (this requires appropriate permissions)
-- CREATE USER MarketingUser WITHOUT LOGIN;

-- Grant permission to the Marketing schema
-- GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Marketing TO MarketingUser;

-- Now MarketingUser can access objects in the Marketing schema, but not in other schemas

-- =============================================
-- Conclusion
-- =============================================

-- This tutorial covered four essential concepts in SQL:
-- 1. Functions (both scalar and table-valued)
-- 2. Stored Procedures (basic and advanced)
-- 3. Indexing (non-clustered and clustered)
-- 4. Schema (creation, usage, and security)

-- We also discussed the important differences between Functions and Stored Procedures.

-- These concepts are fundamental to efficient database design and management.
-- Practice using these concepts to become proficient in SQL development.