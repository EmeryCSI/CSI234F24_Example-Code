--This is a SQL script that when run will totally RESET the Library Schema
DROP TABLE IF EXISTS Library.Borrow;
DROP TABLE IF EXISTS Library.Fine;
DROP TABLE IF EXISTS Library.Member;
DROP TABLE IF EXISTS Library.BookAuthor;
DROP TABLE IF EXISTS Library.Author;
DROP TABLE IF EXISTS Library.Book;
DROP TABLE IF EXISTS Library.Genre;
--If the LIBRARY schema already exists drop it
DROP SCHEMA IF EXISTS Library;
GO
--Create a Schema for the Library
CREATE SCHEMA Library;
GO

--Genre table
--Genre has one-to-many with Book
CREATE TABLE Library.Genre (
	Id int IDENTITY(1,1) PRIMARY KEY,
	GenreName varchar(100)
);
--Book Table
--We have 3 relationships
--Many to one with Genre (FK)
--Many to many with Author (One to many with BookAuthor)
--Many to many with Member (One to Many with Borrow)
CREATE TABLE Library.Book (
	Id int IDENTITY(1,1) PRIMARY KEY,
	Title varchar(255) NOT NULL,
	PublishDate Date,
	PurchaseDate Date,
	GenreId int,
	--Constraint ensures that this genreID exists in the Genre table
	CONSTRAINT FK_Book_Genre FOREIGN KEY (GenreId) REFERENCES Library.Genre(Id)
);
--Author has a Many to Many with Book (BookAuthor Bridge Table)
CREATE TABLE Library.Author (
  Id int IDENTITY(1,1) PRIMARY KEY,
  [FirstName] varchar(100),
  [LastName] varchar(100),
);

--Create BookAuthor (This is a bridge table between Book and Author)
Create Table Library.BookAuthor(
	Id int IDENTITY(1,1) PRIMARY KEY,
	BookId int,
	AuthorId int,
	--Constraints
	CONSTRAINT FK_BookAuthor_Book FOREIGN KEY (BookId) REFERENCES Library.Book(Id),
	CONSTRAINT FK_BookAuthor_Author FOREIGN KEY (AuthorId) REFERENCES Library.Author(Id),
);
-- Create Member
-- Member has one to many with Fine and Borrow
CREATE TABLE Library.Member (
  Id int IDENTITY(1,1) PRIMARY KEY,
  [FirstName] varchar(100) NOT NULL,
  [LastName] varchar(100) NOT NULL,
  Email varchar(150) NOT NULL,
  RegistrationDate Date NOT NULL
);
--Create fine
--Fine has a many to one relationship with Member
CREATE TABLE Library.Fine (
	Id int IDENTITY(1,1) PRIMARY KEY,
	Amount MONEY NOT NULL,
	[Status] varchar(50) NOT NULL,
	MemberId int,
	--Constraint ensures that this MemberId exists in the Member table
	CONSTRAINT FK_Fine_Member FOREIGN KEY (MemberId) REFERENCES Library.Member(Id)
);

--Create Borrow Table
--This is a bridge table between Book and Member
Create Table Library.Borrow(
	Id int IDENTITY(1,1) PRIMARY KEY,
	BorrowDate Date NOT NULL,
	DueDate Date NOT NULL,
	ReturnDate Date,
	BookId int,
	MemberId int,
	--We need our constraints
	CONSTRAINT FK_Borrow_Book FOREIGN KEY (BookId) REFERENCES Library.Book(Id),
	CONSTRAINT FK_Borrow_Member FOREIGN KEY (MemberId) REFERENCES Library.Member(Id),
);

-- Insert sample data into the Genre table
INSERT INTO Library.Genre (GenreName) VALUES
('Fiction'),
('Non-Fiction'),
('Science Fiction'),
('Fantasy'),
('Mystery'),
('Biography'),
('Historical Fiction');

-- Insert sample data into the Author table
INSERT INTO Library.Author (FirstName, LastName) VALUES
('George', 'Orwell'),
('J.K.', 'Rowling'),
('Isaac', 'Asimov'),
('Agatha', 'Christie'),
('Malcolm', 'Gladwell'),
('Yuval', 'Harari');

-- Insert sample data into the Book table
INSERT INTO Library.Book (Title, PublishDate, PurchaseDate, GenreId) VALUES
('1984', '1949-06-08', '2020-01-15', 1),
('Harry Potter and the Sorcerer''s Stone', '1997-06-26', '2020-03-10', 4),
('Foundation', '1951-06-01', '2021-05-20', 3),
('Murder on the Orient Express', '1934-01-01', '2021-07-22', 5),
('Outliers', '2008-11-18', '2022-01-30', 6),
('Sapiens: A Brief History of Humankind', '2011-01-01', '2022-04-11', 6);

-- Insert sample data into the BookAuthor table
INSERT INTO Library.BookAuthor (BookId, AuthorId) VALUES
(1, 1),  -- 1984 by George Orwell
(2, 2),  -- Harry Potter by J.K. Rowling
(3, 3),  -- Foundation by Isaac Asimov
(4, 4),  -- Murder on the Orient Express by Agatha Christie
(5, 5),  -- Outliers by Malcolm Gladwell
(6, 6),  -- Sapiens by Yuval Harari
(1, 2),  -- Additional authors for 1984
(3, 1);  -- Additional authors for Foundation

-- Insert sample data into the Member table
INSERT INTO Library.Member (FirstName, LastName, Email, RegistrationDate) VALUES
('Alice', 'Smith', 'alice.smith@example.com', '2020-01-01'),
('Bob', 'Johnson', 'bob.johnson@example.com', '2021-02-15'),
('Charlie', 'Brown', 'charlie.brown@example.com', '2022-03-20'),
('Daisy', 'Williams', 'daisy.williams@example.com', '2023-04-10');

-- Insert sample data into the Fine table
INSERT INTO Library.Fine (Amount, [Status], MemberId) VALUES
(5.00, 'Unpaid', 1),
(10.00, 'Paid', 2),
(15.00, 'Unpaid', 3),
(20.00, 'Paid', 4);

-- Insert sample data into the Borrow table
INSERT INTO Library.Borrow (BorrowDate, DueDate, ReturnDate, BookId, MemberId) VALUES
('2023-01-15', '2023-02-15', NULL, 1, 1),  -- Alice borrowed 1984
('2023-03-10', '2023-04-10', '2023-04-01', 2, 2),  -- Bob borrowed Harry Potter
('2023-05-20', '2023-06-20', NULL, 3, 3),  -- Charlie borrowed Foundation
('2023-07-22', '2023-08-22', NULL, 4, 4);  -- Daisy borrowed Murder on the Orient Express

SELECT * FROM Library.Book;