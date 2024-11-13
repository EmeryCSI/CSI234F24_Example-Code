-- Drop existing objects if they exist
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HR].[GetEmployeesByDepartment]') AND type IN (N'P'))
    DROP PROCEDURE [HR].[GetEmployeesByDepartment]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[HR].[UpdateEmployeeSalary]') AND type IN (N'P'))
    DROP PROCEDURE [HR].[UpdateEmployeeSalary]
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee_Department' AND schema_id = SCHEMA_ID('HR'))
    DROP TABLE [HR].[Employee_Department]
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee' AND schema_id = SCHEMA_ID('HR'))
    DROP TABLE [HR].[Employee]
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Department' AND schema_id = SCHEMA_ID('HR'))
    DROP TABLE [HR].[Department]
GO

-- Drop schema if exists
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'HR')
    DROP SCHEMA [HR]
GO

-- Create HR Schema
CREATE SCHEMA [HR]
GO

-- Create Tables
CREATE TABLE [HR].[Department] (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(50) NOT NULL,
    Location NVARCHAR(50),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [HR].[Employee] (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(15),
    HireDate DATE,
    Salary DECIMAL(10,2),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
)
GO

CREATE TABLE [HR].[Employee_Department] (
    EmployeeID INT,
    DepartmentID INT,
    StartDate DATE NOT NULL,
    EndDate DATE,
    IsPrimary BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT PK_Employee_Department PRIMARY KEY (EmployeeID, DepartmentID),
    CONSTRAINT FK_Employee_Department_Employee FOREIGN KEY (EmployeeID) 
        REFERENCES [HR].[Employee](EmployeeID),
    CONSTRAINT FK_Employee_Department_Department FOREIGN KEY (DepartmentID) 
        REFERENCES [HR].[Department](DepartmentID)
)
GO

-- Insert Test Data
INSERT INTO [HR].[Department] (DepartmentName, Location) VALUES 
    ('Human Resources', 'New York'),
    ('Information Technology', 'San Francisco'),
    ('Finance', 'Chicago')
GO

INSERT INTO [HR].[Employee] (FirstName, LastName, Email, Phone, HireDate, Salary) VALUES 
    ('John', 'Doe', 'john.doe@company.com', '555-0101', '2020-01-15', 75000.00),
    ('Jane', 'Smith', 'jane.smith@company.com', '555-0102', '2020-03-20', 85000.00),
    ('Bob', 'Johnson', 'bob.johnson@company.com', '555-0103', '2021-02-10', 65000.00)
GO

INSERT INTO [HR].[Employee_Department] (EmployeeID, DepartmentID, StartDate, IsPrimary) VALUES 
    (1, 1, '2020-01-15', 1),
    (2, 2, '2020-03-20', 1),
    (3, 3, '2021-02-10', 1)
GO

-- Create Stored Procedures
CREATE OR ALTER PROCEDURE [HR].[GetEmployeesByDepartment]
    @DepartmentName NVARCHAR(50)
AS
BEGIN
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.Email,
        e.Salary,
        d.DepartmentName,
        ed.StartDate,
        ed.EndDate
    FROM [HR].[Employee] e
    INNER JOIN [HR].[Employee_Department] ed ON e.EmployeeID = ed.EmployeeID
    INNER JOIN [HR].[Department] d ON ed.DepartmentID = d.DepartmentID
    WHERE d.DepartmentName = @DepartmentName
    AND (ed.EndDate IS NULL OR ed.EndDate >= GETDATE())
END
GO

CREATE OR ALTER PROCEDURE [HR].[UpdateEmployeeSalary]
    @EmployeeID INT,
    @NewSalary DECIMAL(10,2),
    @Result NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM [HR].[Employee] WHERE EmployeeID = @EmployeeID)
        BEGIN
            SET @Result = 'Employee not found'
            RETURN
        END

        UPDATE [HR].[Employee] 
        SET Salary = @NewSalary,
            ModifiedDate = GETDATE()
        WHERE EmployeeID = @EmployeeID

        SET @Result = 'Salary updated successfully'
    END TRY
    BEGIN CATCH
        SET @Result = ERROR_MESSAGE()
    END CATCH
END
GO

-- Create Login and User with full access to HR schema
-- Run on Master
CREATE LOGIN HRAdmin 
WITH PASSWORD = 'HR@dm1n2024#';
GO
-- Create Login and User with stored procedure only access
-- RUN ON MASTER
CREATE LOGIN HRReader
WITH PASSWORD = 'HRR3@d2024#';
GO

-- Create database user for HRAdmin
CREATE USER HRAdmin FOR LOGIN HRAdmin;
GO

-- Grant full rights to HR schema for HRAdmin
GRANT CONTROL ON SCHEMA::HR TO HRAdmin;
-- This gives full rights including create, alter, delete objects within the HR schema
GO



-- Create database user for HRReader
CREATE USER HRReader FOR LOGIN HRReader;
GO

-- Deny direct access to tables
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::HR TO HRReader;
GO

-- Grant EXECUTE permission on specific stored procedures
GRANT EXECUTE ON [HR].[GetEmployeesByDepartment] TO HRReader;
GRANT EXECUTE ON [HR].[UpdateEmployeeSalary] TO HRReader;
GO

-- Verify permissions (for administrative purposes)
SELECT 
    dp.name AS [User],
    OBJECT_NAME(p.major_id) AS [Object],
    p.permission_name,
    p.state_desc
FROM sys.database_permissions p
JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
WHERE dp.name IN ('HRAdmin', 'HRReader')
ORDER BY dp.name, OBJECT_NAME(p.major_id);
GO