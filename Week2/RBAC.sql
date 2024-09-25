-- Using SQL Server

-- Step 1: Create logins in the master database
-- Logins are server-level principals used to authenticate users at the server level
-- They are created in the master database because it's the central system database
-- that manages server-wide security and configuration
-- MAKE SURE TO RUN ON MASTER

CREATE LOGIN [ReadOnlyUser] WITH PASSWORD = 'StrongPassword1';
CREATE LOGIN [DataEntryUser] WITH PASSWORD = 'StrongPassword2';
CREATE LOGIN [ManagerUser] WITH PASSWORD = 'StrongPassword3';

--Show all logins in Master
SELECT * FROM sys.sql_logins;

-- Switch to the specific database where we want to create users and set up permissions
-- MAKE SURE TO RUN ON AdventureWorksLT

-- Step 2: Create users in the specific database
-- Users are database-level principals that represent logins within a specific database
-- They are created here because they are specific to this database and its objects
CREATE USER [ReadOnlyUser] FOR LOGIN [ReadOnlyUser];
CREATE USER [DataEntryUser] FOR LOGIN [DataEntryUser];
CREATE USER [ManagerUser] FOR LOGIN [ManagerUser];

-- Step 3: Create roles
-- Roles are groups of users with similar access needs
CREATE ROLE [ReadOnlyRole];
CREATE ROLE [DataEntryRole];
CREATE ROLE [ManagerRole];

-- Step 4: Add users to roles
-- This assigns users to their respective roles
ALTER ROLE [ReadOnlyRole] ADD MEMBER [ReadOnlyUser];
ALTER ROLE [DataEntryRole] ADD MEMBER [DataEntryUser];
ALTER ROLE [ManagerRole] ADD MEMBER [ManagerUser];

-- Step 5: Grant permissions to roles
-- This defines what actions each role can perform

-- ReadOnlyRole: SELECT on all tables in SalesLT schema
-- This allows ReadOnlyRole to view data in all tables within the SalesLT schema
-- Syntax: GRANT PERMISSION ON SCHEMA::{SchemaName} To {ROLE}
GRANT SELECT ON SCHEMA::SalesLT TO [ReadOnlyRole];

-- DataEntryRole: INSERT, UPDATE on specific tables
-- This allows DataEntryRole to add new records and modify existing ones in Customer and SalesOrderHeader tables
GRANT INSERT, UPDATE ON SalesLT.Customer TO [DataEntryRole];
GRANT INSERT, UPDATE ON SalesLT.SalesOrderHeader TO [DataEntryRole];

-- ManagerRole: Full access to all tables in SalesLT schema
-- This gives ManagerRole complete control over all tables in the SalesLT schema
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::SalesLT TO [ManagerRole];

-- New section: Notes on SQL Server Built-in Roles
-- SQL Server provides several built-in roles at both the database and server level
-- that can be used to simplify permission management.

-- Common Database-level roles:
-- db_owner: Can perform all activities in the database
-- db_securityadmin: Can modify role membership and manage permissions
-- db_accessadmin: Can add or remove database access for logins
-- db_datareader: Can read all data from all user tables
-- db_datawriter: Can add, delete, or modify data in all user tables
-- db_ddladmin: Can run any Data Definition Language (DDL) command in the database

-- Example of using a built-in database role:
-- ALTER ROLE db_datareader ADD MEMBER [ReadOnlyUser];

-- Common Server-level roles:
-- sysadmin: Can perform any activity on the server
-- serveradmin: Can change server-wide configuration options
-- securityadmin: Can manage logins, create server roles, and manage server-level permissions
-- processadmin: Can end processes running in the SQL Server instance
-- dbcreator: Can create, alter, drop, and restore any database

-- Example of using a built-in server role:
-- USE master;
-- ALTER SERVER ROLE [dbcreator] ADD MEMBER [SomeLoginName];

-- Benefits of using built-in roles:
-- 1. Simplifies permission management
-- 2. Provides a standardized set of permissions for common scenarios
-- 3. Reduces the risk of forgetting to grant specific permissions

-- Considerations:
-- 1. Built-in roles may provide more permissions than necessary for some users
-- 2. Custom roles might still be needed for more granular control
-- 3. Always follow the principle of least privilege, even when using built-in roles

-- In practice, a combination of built-in roles and custom permissions is often used
-- to balance ease of management with precise access control.

-- The rest of the script continues below...
-- Step 6: Column-level permissions example
-- This demonstrates how to restrict access to specific columns
-- Restrict access to sensitive columns for DataEntryRole
DENY SELECT ON SalesLT.Customer(PasswordHash, PasswordSalt) TO [DataEntryRole];

-- Step 7: Test permissions
-- These tests verify that the permissions are working as intended

-- Test ReadOnlyUser
EXECUTE AS USER = 'ReadOnlyUser'; -- This simulates logging in as ReadOnlyUser
SELECT * FROM SalesLT.Customer; -- This should succeed (can view data)
SELECT * FROM SalesLT.SalesOrderHeader; -- This should succeed (can view data)
-- This should fail (no INSERT permission)
INSERT INTO SalesLT.Customer (FirstName, LastName) VALUES ('Test', 'Customer');
REVERT; -- This ends the simulation of being logged in as ReadOnlyUser

-- Test DataEntryUser
EXECUTE AS USER = 'DataEntryUser'; -- This simulates logging in as DataEntryUser
-- This should succeed (has INSERT permission)
INSERT INTO SalesLT.Customer (FirstName, LastName, CompanyName) VALUES ('New', 'Customer', 'New Company');
-- This should succeed (has UPDATE permission)
UPDATE SalesLT.SalesOrderHeader SET Status = 5 WHERE SalesOrderID = 71774;
-- This should fail (no DELETE permission)
DELETE FROM SalesLT.Customer WHERE CustomerID = 1;
-- This should not return sensitive columns (PasswordHash and PasswordSalt)
SELECT * FROM SalesLT.Customer;
REVERT; -- This ends the simulation of being logged in as DataEntryUser

-- Test ManagerUser
EXECUTE AS USER = 'ManagerUser'; -- This simulates logging in as ManagerUser
-- All of these should succeed (ManagerUser has full permissions)
SELECT * FROM SalesLT.Customer;
INSERT INTO SalesLT.SalesOrderHeader (DueDate, CustomerID, ShipMethod) VALUES (GETDATE(), 1, 'SHIPPING GROUND');
UPDATE SalesLT.Customer SET FirstName = 'Updated' WHERE CustomerID = 1;
DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = 71774;
REVERT; -- This ends the simulation of being logged in as ManagerUser

-- Principle of Least Privilege (POLP)
-- POLP is a security concept where users are given only the minimum levels
-- of access they need to perform their job functions.
-- The permissions in this script demonstrate POLP:
-- - ReadOnlyUser can only view data
-- - DataEntryUser can insert and update specific tables, but can't delete or view sensitive data
-- - ManagerUser has full access, which should be limited to only those who absolutely need it
-- Always review and adjust permissions to ensure users have only the access they need.

-- New section: Creating a user with direct permissions (without using roles)
-- Step 8: Create a new login and user
CREATE LOGIN [DirectPermissionUser] WITH PASSWORD = 'StrongPassword4';
CREATE USER [DirectPermissionUser] FOR LOGIN [DirectPermissionUser];

-- Step 9: Grant direct permissions to the user
-- This user will have specific permissions on tables and columns without being part of a role
GRANT SELECT ON SalesLT.Customer TO [DirectPermissionUser];
GRANT SELECT, INSERT ON SalesLT.SalesOrderHeader TO [DirectPermissionUser];
GRANT UPDATE (Status) ON SalesLT.SalesOrderHeader TO [DirectPermissionUser];
DENY SELECT ON SalesLT.Customer(PasswordHash, PasswordSalt) TO [DirectPermissionUser];

-- Step 10: Test DirectPermissionUser
EXECUTE AS USER = 'DirectPermissionUser';
SELECT * FROM SalesLT.Customer; -- This should succeed (can view data, except sensitive columns)
SELECT * FROM SalesLT.SalesOrderHeader; -- This should succeed (can view all order data)
INSERT INTO SalesLT.SalesOrderHeader (DueDate, CustomerID, ShipMethod) VALUES (GETDATE(), 1, 'SHIPPING GROUND'); -- This should succeed
UPDATE SalesLT.SalesOrderHeader SET Status = 5 WHERE SalesOrderID = 71774; -- This should succeed
UPDATE SalesLT.SalesOrderHeader SET TotalDue = 100 WHERE SalesOrderID = 71774; -- This should fail (no permission on TotalDue column)
INSERT INTO SalesLT.Customer (FirstName, LastName) VALUES ('Test', 'Customer'); -- This should fail (no INSERT permission)
REVERT;

-- Comparison between RBAC and Direct Permissions

-- Role-Based Access Control (RBAC):
-- 1. Scalability: RBAC is more scalable for larger organizations. You can easily add new users
--    to existing roles without modifying individual permissions.
-- 2. Consistency: RBAC ensures consistent permissions across users with similar job functions.
-- 3. Easier management: When permissions need to change, you can modify the role, and all users
--    in that role are automatically updated.
-- 4. Auditing: It's easier to audit who has what permissions by looking at role memberships.
-- 5. Separation of duties: RBAC makes it easier to implement and maintain separation of duties.

-- Direct Permissions:
-- 1. Granularity: Direct permissions allow for very specific, customized access control for individual users.
-- 2. Simplicity for small-scale: For small databases with few users, direct permissions can be simpler to set up initially.
-- 3. Fine-tuned control: You can easily give a user a unique set of permissions that doesn't fit into predefined roles.
-- 4. No role proliferation: Avoids creating too many roles for users with unique permission requirements.

-- Considerations:
-- - RBAC is generally preferred for larger systems or when planning for growth, as it's more manageable long-term.
-- - Direct permissions can be useful for exceptions or very small systems, but can become hard to manage as the system grows.
-- - A hybrid approach is often used, where roles cover most cases, and direct permissions are used for exceptions.

-- Best Practices:
-- 1. Start with RBAC for most users and permissions.
-- 2. Use direct permissions sparingly, only for exceptions that don't fit well into your role structure.
-- 3. Regularly review and audit both role-based and direct permissions.
-- 4. Document the reasons for any direct permissions to aid in future audits and management.