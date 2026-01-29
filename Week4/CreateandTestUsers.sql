-- Lets make some Logins for our library schema
-- CREATE LOGINS ON MASTER
CREATE LOGIN LibraryAdminLogin WITH PASSWORD = 'StrongPassword1!';
CREATE LOGIN LibrarySPLogin WITH PASSWORD = 'StrongPassword123!';
-- CREATE USERS on the database
CREATE USER LibraryAdmin FOR LOGIN LibraryAdminLogin;
CREATE USER LibrarySP FOR LOGIN LibrarySPLogin;
-- Add permissions
-- LibraryAdmin has full access to the Library Schema
GRANT CONTROL ON SCHEMA::Library TO LibraryAdmin;
-- Create a role for Store Procedure Only
CREATE ROLE db_execute_stored_procedure;
--Give permissions to that role
GRANT EXECUTE ON SCHEMA::Library TO db_execute_stored_procedure;
--Assign our login to the role
ALTER ROLE db_execute_stored_procedure ADD MEMBER LibrarySP;
GO

EXECUTE AS USER = 'LibraryAdmin';
SELECT * FROM Library.Author;
REVERT;
GO
--Make a stored prodecure for SP user
CREATE OR ALTER PROCEDURE Library.GetBookGenre 
	@BookId int
AS
BEGIN
	SELECT b.Title, g.GenreName
	FROM Library.Book AS b
	JOIN Library.Genre AS g
	ON b.GenreId = g.Id
	WHERE b.Id = @BookId
END
GO
--This fails because SP user has Stored Procedure only access
EXECUTE AS USER = 'LibrarySP';
SELECT * FROM Library.Author;
REVERT;
-- This user can only run stored procedures.
EXECUTE AS USER = 'LibrarySP';
EXEC Library.GetBookGenre @BookId = 2;
REVERT;

