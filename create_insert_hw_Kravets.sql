/*1) Create two tables in two different ways using CREATE statement
(the table must have at least 5 columns).*/

-- First I will switch to the database I'll be creating new tables in (in my case it's P_STORE)
USE P_STORE
GO

-- Then I will delete table I'm going to create if it exists
DROP TABLE IF EXISTS epam_student;

-- Once it's done, I will create the first table
CREATE TABLE epam_student (
	id INT PRIMARY KEY IDENTITY(1, 1),
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(50) NOT NULL,
	phone VARCHAR(12) NOT NULL,
	city VARCHAR(50),
	result float
	);

-- Let's check
SELECT * FROM epam_student;

/* And here's the 2nd way of creating another table. I will use WHERE clause to transfer
those students who finished course with average mark of 4 or higher*/

-- Once again, first we drop table if exists
DROP TABLE IF EXISTS epam_employee;

-- And create new table
SELECT
	first_name
	,last_name
	,email
	,phone
	,city
INTO epam_employee
FROM epam_student
WHERE result >= 4; -- there isn't results yet, of course

-- Let's check
SELECT * FROM epam_employee;

/*2) Fill the table with data using Insert statement (at least 20 records).*/

-- First we truncate this table (I will populate epam_student)
TRUNCATE TABLE epam_student;

-- And then insert new values
INSERT INTO epam_student
VALUES	('Andriy', 'Bodgan', 'test1@test.com', '380501112233', 'Kyiv', 3.9),
		('Bill', 'Gates', 'test2@test.com', '380501112233', 'Kyiv', 4.9),
		('Francesco', 'Gates', 'test3@test.com', '380501112233', 'Kyiv', 4.2),
		('Melinda', 'Gates', 'test4@test.com', '380501112233', 'Kyiv', 4.8),
		('Mary', 'Jackson', 'test20@test.com', '380501112233', 'Kyiv', 4.1),
		('Bill', 'Jobs', 'test21@test.com', '380501112233', 'Kyiv', 4.2),
		('Steve', 'Jobs', 'test5@test.com', '380501112233', 'Kyiv', 3.9),
		('Steve', 'Gates', 'test6@test.com', '380501112233', 'Kyiv', 4.9),
		('Bob', 'Jobs', 'test7@test.com', '380501112233', 'Kyiv', 4.8),
		('Paul', 'Gates', 'test8@test.com', '380501112233', 'Kyiv', 4.7),
		('Ringo', 'Gates', 'test9@test.com', '380501112233', 'Kyiv', 3.9),
		('John', 'Gates', 'test10@test.com', '380501112233', 'Kyiv', 3.7),
		('Sam', 'Gates', 'test11@test.com', '380501112233', 'Kyiv', 3.6),
		('Will', 'Gates', 'test12@test.com', '380501112233', 'Kyiv', 3.5),
		('Garry', 'Gates', 'test13@test.com', '380501112233', 'Kyiv', 4.1),
		('Sandro', 'Gates', 'test14@test.com', '380501112233', 'Kyiv', 4.2),
		('Fabio', 'Gates', 'test15@test.com', '380501112233', 'Kyiv', 4.4),
		('Alex', 'Gates', 'test16@test.com', '380501112233', 'Kyiv', 4.0),
		('Gigi', 'Gates', 'test17@test.com', '380501112233', 'Kyiv', 4.0),
		('Billy', 'Gates', 'test18@test.com', '380501112233', 'Kyiv', 3.9),
		('Sandra', 'Gates', 'test19@test.com', '380501112233', 'Kyiv', 2.9),
		('Andriy', 'Portnov', 'test0@test.com', '380501112233', 'Kyiv', 4.8);

-- Let's check
SELECT * FROM epam_student
--WHERE result >= 4

/* We can also populate the table with data from other table
For example, we may fill the epam_employee table with epam_student data, filtering it with WHERE clause*/

INSERT INTO epam_employee(first_name, last_name, email, phone, city)
SELECT
	first_name
	,last_name
	,email
	,phone
	,city
FROM epam_student
WHERE result >= 4;

-- Let's check
SELECT * FROM epam_employee;

/*There is also another way to fill the table. We can do it using data from multiple tables in my P_STORE database*/

-- First we truncate this table (I will populate epam_employee)
TRUNCATE TABLE epam_employee;

/* Then I will fill the epam_employee with all the fields from epam_student except phone, which I will get
from abother table by joining it on epam_employee id  */
INSERT INTO epam_employee(first_name, last_name, email, phone, city)
SELECT
	es.first_name
	,es.last_name
	,es.email
	,dc.client_tlf
	,es.city
FROM epam_student es
LEFT JOIN dbo.clients dc ON dc.client_id = es.id
WHERE es.result >= 4;

-- Let's check
SELECT * FROM epam_employee;
