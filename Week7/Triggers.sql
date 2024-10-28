/*
SQL Server Triggers Tutorial
--------------------------
Triggers are special stored procedures that automatically execute when specific events occur in a database.

TYPES OF TRIGGERS:
1. AFTER Triggers (Also called FOR triggers)
   - Execute AFTER the triggering action completes
   - Can't modify the inserted/updated/deleted data
   - Good for audit logging, secondary actions

2. INSTEAD OF Triggers
   - Replace the triggering action
   - Can modify or prevent the data modification
   - Good for complex validation, data transformation

TRIGGER TABLES:
- INSERTED: Virtual table containing new data (INSERT/UPDATE operations)
- DELETED: Virtual table containing old data (DELETE/UPDATE operations)
- For UPDATE operations, compare INSERTED vs DELETED to see what changed

TRIGGER BEST PRACTICES:
1. Keep triggers lightweight and fast
2. Don't use triggers for business logic that could be done elsewhere
3. Always use SET NOCOUNT ON to reduce network traffic
4. Consider using AFTER triggers for audit logging
5. Use INSTEAD OF triggers when you need to modify or validate data before changes
*/

USE AdventureWorksLT2019;
GO

-- First, let's create tables in the SalesLT schema
-- Drop existing objects if they exist
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'SimpleTable' AND SCHEMA_NAME(schema_id) = 'SalesLT')
    DROP TABLE [SalesLT].[SimpleTable];
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'SimpleTableHistory' AND SCHEMA_NAME(schema_id) = 'SalesLT')
    DROP TABLE [SalesLT].[SimpleTableHistory];
GO

-- Simple table for basic demonstrations
CREATE TABLE [SalesLT].[SimpleTable]
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Description VARCHAR(50),
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastModifiedDate DATETIME
);
GO

-- History table for tracking all changes
CREATE TABLE [SalesLT].[SimpleTableHistory]
(
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    ID INT,
    Description VARCHAR(50),
    CreatedDate DATETIME,
    LastModifiedDate DATETIME,
    ChangeType VARCHAR(10),  -- INSERT, UPDATE, DELETE
    ChangedBy NVARCHAR(128), -- User who made the change
    ChangedDate DATETIME DEFAULT GETDATE(),
    OldValue VARCHAR(MAX),   -- JSON representation of old record
    NewValue VARCHAR(MAX)    -- JSON representation of new record
);
GO

/*
EXAMPLE 1: Simple AFTER INSERT Trigger
This trigger demonstrates:
- Basic trigger structure
- How to access INSERTED table
- Simple logging
- Using PRINT for debugging
*/
CREATE OR ALTER TRIGGER [SalesLT].[tr_SimpleTable_AfterInsert]
ON [SalesLT].[SimpleTable]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;    -- Prevents sending affected rows message to client
    
    -- Debug message
    PRINT 'AFTER INSERT Trigger fired!'
    -- Show what was inserted (great for learning/debugging)
    PRINT 'Newly inserted data:';
    SELECT * FROM INSERTED;
    
    -- Update LastModifiedDate
    UPDATE [SalesLT].[SimpleTable]
    SET LastModifiedDate = GETDATE()
    WHERE ID IN (SELECT ID FROM INSERTED);
END;
GO

-- Test INSERT trigger
PRINT '=== Test 1: AFTER INSERT Trigger ===';
INSERT INTO [SalesLT].[SimpleTable] (Description) 
VALUES ('Test Item 1');
GO

-- View results after INSERT
SELECT 'SimpleTable Contents After INSERT:' AS Message;
SELECT * FROM [SalesLT].[SimpleTable];
GO

/*
EXAMPLE 3: Simple AFTER DELETE Trigger
This trigger demonstrates:
- How to access DELETED table
- Logging deleted records
- Preventing cascading triggers with SET NOCOUNT ON
*/
CREATE OR ALTER TRIGGER [SalesLT].[tr_SimpleTable_AfterDelete]
ON [SalesLT].[SimpleTable]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT 'AFTER DELETE Trigger fired!';
    
    -- Show what was deleted
    PRINT 'Deleted data:';
    SELECT * FROM DELETED;
END;
GO

-- Test DELETE trigger
PRINT '=== Test 3: AFTER DELETE Trigger ===';
DELETE FROM [SalesLT].[SimpleTable] 
WHERE ID = 1;
GO

-- View results after DELETE
SELECT 'SimpleTable Contents After DELETE:' AS Message;
SELECT * FROM [SalesLT].[SimpleTable];
GO


/*
EXAMPLE 2: Simple AFTER UPDATE Trigger
This trigger demonstrates:
- How to access both INSERTED and DELETED tables
- Comparing old vs new values
- More complex logging
*/
CREATE OR ALTER TRIGGER [SalesLT].[tr_SimpleTable_AfterUpdate]
ON [SalesLT].[SimpleTable]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT 'AFTER UPDATE Trigger fired!';
    
    -- Show what changed
    PRINT 'Old values (DELETED table):';
    SELECT * FROM DELETED;
    
    PRINT 'New values (INSERTED table):';
    SELECT * FROM INSERTED;
    
    -- Show specific changes
    SELECT 
        i.ID,
        d.Description AS OldDescription,
        i.Description AS NewDescription,
        'Description was changed' AS ChangeType
    FROM INSERTED i
    JOIN DELETED d ON i.ID = d.ID
    WHERE i.Description <> d.Description;
END;
GO

-- Test UPDATE trigger
PRINT '=== Test 2: AFTER UPDATE Trigger ===';
UPDATE [SalesLT].[SimpleTable] 
SET Description = 'Modified Test Item 1'
WHERE Description = 'Test Item 1';
GO

-- View results after UPDATE
SELECT 'SimpleTable Contents After UPDATE:' AS Message;
SELECT * FROM [SalesLT].[SimpleTable];
GO


/*
EXAMPLE 4: INSTEAD OF INSERT Trigger with Validation
This trigger demonstrates:
- Replacing default INSERT behavior
- Data validation
- Conditional execution
- Error handling
*/
CREATE OR ALTER TRIGGER [SalesLT].[tr_SimpleTable_InsteadOfInsert]
ON [SalesLT].[SimpleTable]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT '? INSTEAD OF INSERT Trigger fired!';
    
    -- Validate data
    IF EXISTS (SELECT 1 FROM INSERTED WHERE Description IS NULL OR Description = '')
    BEGIN
        PRINT 'Insert rejected - Description cannot be empty';
        RAISERROR ('Description cannot be empty', 16, 1);
        RETURN;
    END;
    
    -- If validation passes, perform the insert with our custom logic
    INSERT INTO [SalesLT].[SimpleTable] (Description, CreatedDate, LastModifiedDate)
    SELECT 
        UPPER(Description),  -- Convert to uppercase
        GETDATE(),          -- Set current date
        GETDATE()
    FROM INSERTED;
    
    PRINT 'Insert completed with custom logic';
END;
GO

-- Test INSTEAD OF INSERT trigger
PRINT '=== Test 4: INSTEAD OF INSERT Trigger ===';
-- This should fail
PRINT 'Testing invalid insert (empty description):';
BEGIN TRY
    INSERT INTO [SalesLT].[SimpleTable] (Description) VALUES ('');
END TRY
BEGIN CATCH
    PRINT 'Error caught: ' + ERROR_MESSAGE();
END CATCH
GO

-- This should succeed and convert to uppercase
PRINT 'Testing valid insert (will be converted to uppercase):';
INSERT INTO [SalesLT].[SimpleTable] (Description) VALUES ('test item 2');
GO

-- View results after INSTEAD OF INSERT tests
SELECT 'SimpleTable Contents After INSTEAD OF INSERT Tests:' AS Message;
SELECT * FROM [SalesLT].[SimpleTable];
GO

/*
ADVANCED EXAMPLE: History Tracking Triggers
These triggers demonstrate:
- Complete change tracking
- JSON data storage
- Audit trail implementation
- Multiple trigger coordination
*/

/*
History trigger for INSERT operations
This trigger will:
1. Log the inserted record
2. Track who made the change
3. Store the new values in JSON format
*/
/*
FOR JSON PATH Explanation
------------------------
The FOR JSON PATH clause converts SQL Server data into JSON format.

Key Components:
1. SELECT ... FOR JSON PATH - Basic syntax for JSON conversion
2. WITHOUT_ARRAY_WRAPPER - Returns a JSON object instead of an array
3. PATH - Determines how the JSON is structured

Let's break this down with examples:
*/
--SELECT TOP 1 * FROM SALESLT.Customer FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
CREATE OR ALTER TRIGGER [SalesLT].[tr_SimpleTable_History_Insert]
ON [SalesLT].[SimpleTable]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [SalesLT].[SimpleTableHistory]
    (
        ID,
        Description,
        CreatedDate,
        LastModifiedDate,
        ChangeType,
        ChangedBy,
        OldValue,
        NewValue
    )
    SELECT
        i.ID,
        i.Description,
        i.CreatedDate,
        i.LastModifiedDate,
        'INSERT',
        SYSTEM_USER,
        NULL, -- No old value for INSERT
        (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) -- New values in JSON
    FROM INSERTED i;
END;
GO

-- Test History INSERT Trigger
PRINT '=== Test 5: History INSERT Trigger ===';
INSERT INTO [SalesLT].[SimpleTable] (Description)
VALUES ('History Test Item 1');
GO
SELECT * FROM SalesLt.SimpleTableHistory;
GO
/*
History trigger for UPDATE operations
This trigger will:
1. Log both old and new values
2. Track who made the change
3. Store before/after values in JSON format
*/
CREATE OR ALTER TRIGGER [SalesLT].[tr_SimpleTable_History_Update]
ON [SalesLT].[SimpleTable]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [SalesLT].[SimpleTableHistory]
    (
        ID,
        Description,
        CreatedDate,
        LastModifiedDate,
        ChangeType,
        ChangedBy,
        OldValue,
        NewValue
    )
    SELECT
        i.ID,
        i.Description,
        i.CreatedDate,
        i.LastModifiedDate,
        'UPDATE',
        SYSTEM_USER,
        (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER), -- Old values
        (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)  -- New values
    FROM INSERTED i
    JOIN DELETED d ON i.ID = d.ID
    WHERE i.Description <> d.Description  -- Only log if something actually changed
       OR i.LastModifiedDate <> d.LastModifiedDate;
END;
GO

-- Test History UPDATE Trigger
PRINT '=== Test 6: History UPDATE Trigger ===';
UPDATE [SalesLT].[SimpleTable]
SET Description = 'Modified History Item 1'
WHERE Description = 'History Test Item 1';
GO

/*
History trigger for DELETE operations
This trigger will:
1. Log the deleted record
2. Track who made the change
3. Store the old values in JSON format
*/
CREATE OR ALTER TRIGGER [SalesLT].[tr_SimpleTable_History_Delete]
ON [SalesLT].[SimpleTable]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [SalesLT].[SimpleTableHistory]
    (
        ID,
        Description,
        CreatedDate,
        LastModifiedDate,
        ChangeType,
        ChangedBy,
        OldValue,
        NewValue
    )
    SELECT
        d.ID,
        d.Description,
        d.CreatedDate,
        d.LastModifiedDate,
        'DELETE',
        SYSTEM_USER,
        (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER), -- Old values
        NULL  -- No new values for DELETE
    FROM DELETED d;
END;
GO

-- Test History DELETE Trigger
PRINT '=== Test 7: History DELETE Trigger ===';
DELETE FROM [SalesLT].[SimpleTable]
WHERE Description = 'Modified History Item 1';
GO

-- Example of using the history procedure
DECLARE @LastID INT = (SELECT TOP 1 ID FROM [SalesLT].[SimpleTableHistory] ORDER BY HistoryID DESC);
PRINT 'History for Last ID:';
EXEC [SalesLT].[usp_GetSimpleTableHistory] @ID = @LastID;

-- Cleanup script (commented out by default)

-- Drop triggers
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'tr_SimpleTable_AfterInsert' AND parent_id = OBJECT_ID('[SalesLT].[SimpleTable]'))
    DROP TRIGGER [SalesLT].[tr_SimpleTable_AfterInsert];
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'tr_SimpleTable_AfterUpdate' AND parent_id = OBJECT_ID('[SalesLT].[SimpleTable]'))
    DROP TRIGGER [SalesLT].[tr_SimpleTable_AfterUpdate];
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'tr_SimpleTable_AfterDelete' AND parent_id = OBJECT_ID('[SalesLT].[SimpleTable]'))
    DROP TRIGGER [SalesLT].[tr_SimpleTable_AfterDelete];
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'tr_SimpleTable_InsteadOfInsert' AND parent_id = OBJECT_ID('[SalesLT].[SimpleTable]'))
    DROP TRIGGER [SalesLT].[tr_SimpleTable_InsteadOfInsert];
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'tr_SimpleTable_History_Insert' AND parent_id = OBJECT_ID('[SalesLT].[SimpleTable]'))
    DROP TRIGGER [SalesLT].[tr_SimpleTable_History_Insert];
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'tr_SimpleTable_History_Update' AND parent_id = OBJECT_ID('[SalesLT].[SimpleTable]'))
    DROP TRIGGER [SalesLT].[tr_SimpleTable_History_Update];
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'tr_SimpleTable_History_Delete' AND parent_id = OBJECT_ID('[SalesLT].[SimpleTable]'))
    DROP TRIGGER [SalesLT].[tr_SimpleTable_History_Delete];

-- Drop tables
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'SimpleTable' AND SCHEMA_NAME(schema_id) = 'SalesLT')
    DROP TABLE [SalesLT].[SimpleTable];
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'SimpleTableHistory' AND SCHEMA_NAME(schema_id) = 'SalesLT')
    DROP TABLE [SalesLT].[SimpleTableHistory];


