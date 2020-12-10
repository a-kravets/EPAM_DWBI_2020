/*
1. Do the following tasks:
1) Create a table with the following constraints:
- PRIMARY KEY;
- CHECK;
- DEFAULT;
- UNIQUE.
The name of the table should start with the first letter of your last name,
the number of columns and filling in the table is at your discretion.
*/

DROP TABLE IF EXISTS Kravets;
CREATE TABLE Kravets (
	ID int IDENTITY(1,1) PRIMARY KEY, -- primary key
	LastName varchar(255) NOT NULL,
	FirstName varchar(255) NOT NULL,
	Age int NOT NULL,
	Email varchar(120) NOT NULL UNIQUE, -- unique
	Phone int NOT NULL UNIQUE,
	Status varchar(3) DEFAULT 'no', -- default
	CHECK(Age >= 18) -- check
);

SELECT * FROM Kravets

-- general check up
INSERT INTO Kravets(LastName, FirstName, Age, Email, Phone)
VALUES('Surname', 'Name', 18, 'a@a.com', 2533333)

-- UNIQUE email checkup
INSERT INTO Kravets(LastName, FirstName, Age, Email, Phone)
VALUES('Surname', 'Name', 18, 'a@a.com', 3566766)

-- Age CHECK check up
INSERT INTO Kravets(LastName, FirstName, Age, Email, Phone)
VALUES('Surname', 'Name', 17, 'a@a.com', 2533333)

-- NOT NULL checkup
INSERT INTO Kravets(LastName, FirstName, Age, Email)
VALUES('Surname', 'Name', 18, 'a1@a.com')

/*
2) Create a script that displays the first three "OrderQTY" with repeating values in descending order
from the "Sales.SalesOrderDetail" table (USE AdventureWorks2019).
As a result, display the columns: "OrderQTY", "SalesOrderId", "UnitPrice".
*/

USE AdventureWorks2019_Kravets

SELECT
	TOP 3 WITH TIES OrderQTY
	,SalesOrderId
	,UnitPrice
FROM Sales.SalesOrderDetail
ORDER BY OrderQTY DESC

/*
3) Create a script that displays all products from Production.Product table and
any price they might have from Sales.SalesOrderDetail table (USE AdventureWorks2019).
As a result, display the columns: "Name", "UnitPrice".
*/

SELECT
	Name
	,UnitPrice
FROM Production.Product pp
LEFT JOIN Sales.SalesOrderDetail ssod ON pp.ProductID = ssod.ProductID

/*
4) Invert the value of the Task column (Homework table) in reverse order without using the Reverse function.
Create table Homework2(
Task varchar(20)
);
INSERT INTO Homework2 VALUES ('1234567890');
SELECT REVERSE(Task) AS FIELD1 FROM Homework2; -- You should get the same result
*/

USE P_STORE -- using my testing database

-- creating the table, inserting values and chacking the result set
Create table Homework2(
	Task varchar(20)
);
INSERT INTO Homework2 VALUES ('1234567890');
SELECT REVERSE(Task) AS FIELD1 FROM Homework2;

-- Reverse function
-- I'll use while loop to copy and paste one charachter at a time
CREATE FUNCTION REVERSE_VALUE(@input_field varchar(20)) -- we'll get one variable for the reverse
RETURNS varchar(20) -- and will return an output with the same data type
BEGIN
	DECLARE @counter int -- declare our counter for controling lenght of the variable
	DECLARE @len_field int -- declare variable for lenght of the field
	DECLARE @output_field varchar(20) -- declare out future output variable
	SET @counter = 1 -- set counter to 1
	SET @len_field = LEN(@input_field) -- set len_field varible to the lenght of the input field
	SET @output_field = '' -- set resulting variable to ''
	-- we'll use while loop to paste charachters from input to output one by one
	WHILE @len_field >= @counter -- while lenght of the field is bigger or equal to our counter do
		BEGIN
			-- we'll paste to our output one charachter at a time from the input/soure field starting from right
			SET @output_field = CONCAT(@output_field, RIGHT(@input_field, 1))
			-- we'll delete one charachter from input we have already pasted to putput
			SET @input_field = LEFT(@input_field, @len_field-@counter)
			-- we'll increase our ounter by 1 to control how many charachters we've already pasted
			SET @counter += 1
		END
	RETURN @output_field -- this will return the result
END

-- Let's check and compare
SELECT dbo.REVERSE_VALUE(Task) AS FIELD1 FROM Homework2;
SELECT REVERSE(Task) AS FIELD1 FROM Homework2;


/*
5) Create a script that displays the first (minimum) skipped ID from TABLE LOST_ID_TASK.
CREATE TABLE LOST_ID_TASK(
LOST_ID int
);
INSERT INTO LOST_ID_TASK (LOST_ID) VALUES (1);
INSERT INTO LOST_ID_TASK (LOST_ID) VALUES (2);
INSERT INTO LOST_ID_TASK (LOST_ID) VALUES (4);
INSERT INTO LOST_ID_TASK (LOST_ID) VALUES (5);
INSERT INTO LOST_ID_TASK (LOST_ID) VALUES (7);
INSERT INTO LOST_ID_TASK (LOST_ID) VALUES (8);
INSERT INTO LOST_ID_TASK (LOST_ID) VALUES (9);
INSERT INTO LOST_ID_TASK (LOST_ID) VALUES (10);
*/

-- creating the table and inserting values
CREATE TABLE LOST_ID_TASK(
	LOST_ID int
);
INSERT INTO LOST_ID_TASK (LOST_ID) VALUES (1);
INSERT INTO LOST_ID_TASK (LOST_ID) VALUES (2);
INSERT INTO LOST_ID_TASK (LOST_ID) VALUES (4);
INSERT INTO LOST_ID_TASK (LOST_ID) VALUES (5);
INSERT INTO LOST_ID_TASK (LOST_ID) VALUES (7);
INSERT INTO LOST_ID_TASK (LOST_ID) VALUES (8);
INSERT INTO LOST_ID_TASK (LOST_ID) VALUES (9);
INSERT INTO LOST_ID_TASK (LOST_ID) VALUES (10);

-- checking 
SELECT * FROM LOST_ID_TASK;

-- I will first create a CTE table with LOST_ID and DENSE_RANK to be able to compare them later
WITH Missing AS
(
	SELECT
		LOST_ID
		,DENSE_RANK() OVER(ORDER BY LOST_ID) AS missing_id
	FROM LOST_ID_TASK
)
-- now I will get TOP 1 id where (rank <> LOST_ID) and apply ascending order, which will give me the min missing id
SELECT TOP 1 missing_id
FROM Missing
WHERE missing_id <> LOST_ID
ORDER BY missing_id ASC;

