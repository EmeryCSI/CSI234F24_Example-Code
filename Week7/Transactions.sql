/*
What are ACID Properties?
- Atomicity: Think of it like an all-or-nothing operation. Either all steps complete successfully,
            or none of them do. It's like transferring money between bank accounts - either both
            accounts are updated or neither is.
            
- Consistency: The database must remain in a valid state before and after the transaction.
              Think of it like maintaining a balanced checkbook - credits and debits must match.
              
- Isolation: Multiple transactions running at the same time shouldn't interfere with each other.
            It's like multiple cashiers at a store - they can all process different customers
            without mixing up the transactions.
            
- Durability: Once a transaction is committed (completed successfully), the changes are permanent
              and survive any system crashes. Like writing in pen instead of pencil.

Special SQL Server Variables:
@@TRANCOUNT - A built-in variable that keeps track of how many transactions are currently active
- When we BEGIN TRANSACTION, it goes up by 1
- When we COMMIT, it goes down by 1
- When we ROLLBACK, it goes to 0
@@ERROR - Contains the error number of the last error that occurred
@@ROWCOUNT - Contains the number of rows affected by the last statement
*/


-- Example 1: Basic Transaction Structure
-- Demonstrates Atomicity - either both operations succeed or both fail
PRINT 'Example 1: Basic Transaction with Error Handling';
GO

BEGIN TRY
    -- Start a new transaction - think of this like opening a new batch of changes
    BEGIN TRANSACTION;
        -- First change: Update customer's email
        UPDATE SalesLT.Customer
        SET EmailAddress = 'new.email@example.com'
        WHERE CustomerID = 1;

        -- Second change: Update the timestamp for when we modified their address
        UPDATE SalesLT.CustomerAddress
        SET ModifiedDate = GETDATE()  -- GETDATE() is like DateTime.Now in other languages
        WHERE CustomerID = 1;

    -- If we got here, both updates worked! Make the changes permanent
    COMMIT TRANSACTION;
    PRINT 'Transaction committed successfully';
END TRY
BEGIN CATCH
    -- Something went wrong - this is like a catch block in other programming languages
    -- Check if we're in the middle of a transaction (@@TRANCOUNT > 0 means we are)
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;  -- Undo all changes
    
    PRINT 'Error occurred. Transaction rolled back.';
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH;
GO

/*
Typically transactions will be used from inside of a stored procedure.
*/

-- Example 1: Simple Transaction in a Stored Procedure
-- This procedure updates a product's price with a basic transaction
PRINT '--- Example 1: Simple Transaction ---';
GO

CREATE OR ALTER PROCEDURE SalesLT.UpdateProductPrice
    @ProductID int,
    @NewPrice money
AS
BEGIN
    BEGIN TRY
        -- Start the transaction
        BEGIN TRANSACTION;
            
            -- Try to update the price
            UPDATE SalesLT.Product
            SET ListPrice = @NewPrice,
                ModifiedDate = GETDATE()
            WHERE ProductID = @ProductID;

            -- Check if we found the product
            IF @@ROWCOUNT = 0
            BEGIN
                -- No product found - roll back
                ROLLBACK TRANSACTION;
                PRINT 'Product not found!';
                RETURN;
            END

        -- Everything worked - commit the change
        COMMIT TRANSACTION;
        PRINT 'Price updated successfully!';
    END TRY
    BEGIN CATCH
        -- Something went wrong
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

-- Test 1: Success case - update a price that exists
PRINT 'Test 1: Update existing product (should succeed)';
EXEC SalesLT.UpdateProductPrice @ProductID = 680, @NewPrice = 1000.00;
GO

-- Test 2: Failure case - try to update product that doesn't exist
PRINT 'Test 2: Update non-existent product (should fail)';
EXEC SalesLT.UpdateProductPrice @ProductID = 99999, @NewPrice = 1000.00;
GO

-- Example 2: Transaction with Two Updates
-- This procedure updates both price and name - shows how transactions
-- keep multiple updates together
PRINT '--- Example 2: Transaction with Two Updates ---';
GO

CREATE OR ALTER PROCEDURE SalesLT.UpdateProductPriceAndName
    @ProductID int,
    @NewPrice money,
    @NewName nvarchar(50)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            
            -- Update both price and name
            UPDATE SalesLT.Product
            SET ListPrice = @NewPrice,
                Name = @NewName,
                ModifiedDate = GETDATE()
            WHERE ProductID = @ProductID;

            -- Check if we found the product
            IF @@ROWCOUNT = 0
            BEGIN
                ROLLBACK TRANSACTION;
                PRINT 'Product not found!';
                RETURN;
            END

            -- Try to add a log entry (this will fail if price is negative)
            IF @NewPrice < 0
            BEGIN
                -- Simulate a business rule violation
                RAISERROR('Price cannot be negative!', 16, 1);
            END

        COMMIT TRANSACTION;
        PRINT 'Product updated successfully!';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

-- Test 3: Success case - update both price and name
PRINT 'Test 3: Update price and name (should succeed)';
EXEC SalesLT.UpdateProductPriceAndName 
    @ProductID = 680, 
    @NewPrice = 1000.00,
    @NewName = 'Updated Product Name';
GO

-- Test 4: Failure case - try to set negative price
PRINT 'Test 4: Set negative price (should fail)';
EXEC SalesLT.UpdateProductPriceAndName 
    @ProductID = 680, 
    @NewPrice = -100.00,
    @NewName = 'Should Not Update';
GO

-- Example 3: Simple Savepoint Example
-- Shows how to roll back part of a transaction
PRINT '--- Example 3: Simple Savepoint Example ---';
GO

CREATE OR ALTER PROCEDURE SalesLT.UpdateMultipleProducts
    @CategoryID int,
    @PriceIncrease decimal(5,2)  -- Percentage increase
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            
            -- Save starting point
            SAVE TRANSACTION StartPoint;

            -- Update all products in category
            UPDATE SalesLT.Product
            SET ListPrice = ListPrice * (1 + (@PriceIncrease / 100))
            WHERE ProductCategoryID = @CategoryID;

            -- If any price is over 5000, roll back just the price updates
            IF EXISTS (SELECT 1 FROM SalesLT.Product WHERE ListPrice > 5000)
            BEGIN
                ROLLBACK TRANSACTION StartPoint;
                PRINT 'Rolled back price changes - some prices would be too high';
            END
            ELSE
            BEGIN
                COMMIT TRANSACTION;
                PRINT 'All prices updated successfully';
            END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

-- Test 5: Success case - small price increase
PRINT 'Test 5: Small price increase (should succeed)';
EXEC SalesLT.UpdateMultipleProducts @CategoryID = 18, @PriceIncrease = 5.0;
GO

-- Test 6: Failure case - large price increase
PRINT 'Test 6: Large price increase (should roll back)';
EXEC SalesLT.UpdateMultipleProducts @CategoryID = 18, @PriceIncrease = 500.0;
GO

/*
Key Points to Remember:
1. Transactions wrap multiple operations together
   - If one fails, they all fail
   - Like moving money between bank accounts - both must succeed or neither happens

2. Basic Transaction Pattern:
   BEGIN TRANSACTION
       Make changes
       Check if everything's okay
   COMMIT or ROLLBACK

3. Always use TRY-CATCH with transactions
   - Catches errors
   - Makes sure we don't leave transactions hanging

4. Testing Transactions:
   - Test success cases (everything works)
   - Test failure cases (something goes wrong)
   - Make sure rollbacks work properly
*/
/*
Key Transaction Best Practices:
1. Always use TRY-CATCH blocks for error handling
   - This is like try-catch in other programming languages
   - Helps you handle errors gracefully

2. Check @@TRANCOUNT before ROLLBACK
   - Makes sure you only roll back if you're actually in a transaction
   - Prevents errors from trying to roll back when there's nothing to roll back

3. Keep transactions as short as possible
   - Long-running transactions can block other users
   - Think of it like holding up a line at a store

4. Use appropriate isolation levels
   - READ COMMITTED (default) - Good for most cases
   - SERIALIZABLE - When you need the strictest data consistency
   - Think of isolation levels like controlling how many people can modify data at once

5. Use SAVE POINTS for complex transactions
   - Lets you roll back part of a transaction without rolling back everything
   - Like having multiple save points in a game

6. Make sure all code paths either COMMIT or ROLLBACK
   - Never leave a transaction hanging
   - Always clean up after yourself