/*
SQL Views
1. Create a view, named NumberCust which is showing how many customers there are on each territory
(use table [Sales].[Customer]).
*/

-- Let's switch to the right db
USE AdventureWorks2019_Kravets
GO

-- First, let's check if there are duplicates in CustomerID
SELECT
	COUNT(sc.CustomerID)
	,COUNT(DISTINCT sc.CustomerID)
FROM Sales.Customer sc

-- Since there are none, we can use COUNT() to get accurate results
CREATE VIEW NumberCust
AS
SELECT 
	sc.TerritoryID -- Territory ID
	,sst.Name -- On top of that I'll add Territory Name so it's more readable and user-friendly
	,COUNT(sc.CustomerID) AS Cust_Num
FROM Sales.Customer sc
LEFT JOIN Sales.SalesTerritory sst ON sst.TerritoryID = sc.TerritoryID -- joining SalesTerritory table to get Territory names
GROUP BY sc.TerritoryID, sst.Name

-- Let's check
SELECT * FROM NumberCust
ORDER BY Cust_Num DESC; -- let's order our results by customers number


/*
SQL Tiggers
1. Construct a trigger, named trgDelete, that is affected DELETE Transact-SQL statements in the [HumanResources].[Department] table.
This trigger should write the data which was deleted to separate table (you need to create this table).*/

-- Let's create a new table
DROP TABLE IF EXISTS HumanResources.DepartmentLog;
CREATE TABLE HumanResources.DepartmentLog (
	DepartmentID smallint NOT NULL,
	Name nvarchar(50) NOT NULL,
	GroupName nvarchar(50) NOT NULL,
	ModifiedDate datetime NOT NULL
);

-- Creating the trigger
CREATE TRIGGER trgDelete
ON [HumanResources].[Department]
AFTER DELETE
AS INSERT INTO HumanResources.DepartmentLog
SELECT * FROM deleted

-- Since all the DepartmentID are used as reference in another table, we cannot delete without cascading
-- So I'll insert new values for this task
INSERT INTO HumanResources.Department
VALUES('New', 'New Group', GETDATE())

-- Checking
SELECT * FROM HumanResources.Department

-- Checking how this new trigger works
DELETE FROM HumanResources.Department
WHERE Name = 'New'

-- It works :)
SELECT * FROM HumanResources.DepartmentLog

/*
2. Construct a trigger, named trgUpdate, that is affected by UPDATE Transact-SQL statements in the [HumanResources].[ vEmployee] view.
This trigger should simply raise an error instead of update that indicates that data cannot be updated at this view.*/

-- Creating the trigger
CREATE TRIGGER trgUpdate
ON HumanResources.vEmployee
INSTEAD OF UPDATE
AS
BEGIN
PRINT 'DATA CANNOT BE UPDATED AT THIS VIEW!'
ROLLBACK TRANSACTION
END

-- Checking
UPDATE [HumanResources].[vEmployee]
SET [PhoneNumberType] = 'Cell'
WHERE MiddleName = 'H'


/*
SQL Stored Procedures
1. Create a stored procedure sp_ChangeCity which changes all Cities in the table [Person].[Address] into Upper Case.*/

-- Creating the proc
CREATE PROCEDURE sp_ChangeCity
AS
SET NOCOUNT ON --number of rows off
UPDATE [Person].[Address]
SET City = UPPER(City)

-- Executing
EXEC sp_ChangeCity

-- Checking
SELECT City FROM [Person].[Address]

/*
2. Construct a stored proc, named sp_GetLastName, that accepts an input parameter named EmployeeID and
returns the last name of that employee.
*/


-- Creating proc with INPUT & OUTPUT
-- We don't have EmployeeID in our AdventureWorks database, but we have BusinessEntityID in Person.Person, which is
-- unique for every employee (there are no duplicates). For this reason we may use BusinessEntityID as our EmployeeID
CREATE PROCEDURE sp_GetLastName
@EmployeeID INT, @LastName varchar(50) OUTPUT
AS
SET NOCOUNT ON
SET @LastName =
(
	SELECT pp.LastName
	FROM Person.Person pp
	WHERE pp.BusinessEntityID = @EmployeeID
)

-- Checking
DECLARE @LastName varchar(50)
EXEC sp_GetLastName 2, @LastName OUTPUT
SELECT @LastName


-- -- Creating proc with params
CREATE PROCEDURE sp_GetLastName2
@EmployeeID INT
AS
SET NOCOUNT ON
	SELECT pp.LastName
	FROM Person.Person pp
	WHERE pp.BusinessEntityID = @EmployeeID

	-- Checking
EXEC sp_GetLastName2 2


/*
SQL XML grouping and ranking functions
1. Use GROUPING SETS, ROLLUP, CUBE with grouping set containing 5 columns.
*/
SELECT * FROM [Sales].[vSalesPerson]
--GROUPING SETS
SELECT 
	[CountryRegionName]
	,[StateProvinceName]
	,[City]
	,[PostalCode]
	,([FirstName] + ' ' + [LastName]) AS 'Sales Person'
	,SUM(SalesYTD) AS 'Sales in USD'
FROM Sales.vSalesPerson 
WHERE [CountryRegionName] IS NOT NULL OR [StateProvinceName] IS NOT NULL
GROUP BY GROUPING SETS
(
	([CountryRegionName]),
	([CountryRegionName], [StateProvinceName]),
	([CountryRegionName], [StateProvinceName], [City]),
	([CountryRegionName], [StateProvinceName], [City], [PostalCode]),
	([CountryRegionName], [StateProvinceName], [City], [PostalCode], ([FirstName] + ' ' + [LastName]))
)

--ROLLUP
SELECT 
	[CountryRegionName]
	,[StateProvinceName]
	,[City]
	,[PostalCode]
	,([FirstName] + ' ' + [LastName]) AS 'Sales Person'
	,SUM(SalesYTD) AS 'Sales in USD'
FROM Sales.vSalesPerson 
WHERE [CountryRegionName] IS NOT NULL OR [StateProvinceName] IS NOT NULL
GROUP BY ROLLUP
(
	[CountryRegionName], [StateProvinceName], [City], [PostalCode], ([FirstName] + ' ' + [LastName])
)

--CUBE
SELECT 
	[CountryRegionName]
	,[StateProvinceName]
	,[City]
	,[PostalCode]
	,([FirstName] + ' ' + [LastName]) AS 'Sales Person'
	,SUM(SalesYTD) AS 'Sales in USD'
FROM Sales.vSalesPerson 
WHERE [CountryRegionName] IS NOT NULL OR [StateProvinceName] IS NOT NULL
GROUP BY CUBE
(
	[CountryRegionName], [StateProvinceName], [City], [PostalCode], ([FirstName] + ' ' + [LastName])
)


/*
SQL XML data-types
1. Create your own XML script (root must containt your name, e.g. <bookstore_NameSurname>) and convert it into table.
*/

-- Declaring and storing my XML
DECLARE @my_xml XML
SET @my_xml = 
'<exchangerates_AndriyKravets>

	<exchangerates>
		<exchangerate ccy="USD" base_ccy="UAH" buy="27.90000" sale="28.33000"/>
	</exchangerates>

	<exchangerates>
		<exchangerate ccy="EUR" base_ccy="UAH" buy="33.70000" sale="34.30000"/>
	</exchangerates>

	<exchangerates>
		<exchangerate ccy="RUR" base_ccy="UAH" buy="0.36000" sale="0.40000"/>
	</exchangerates>

	<exchangerates>
		<exchangerate ccy="BTC" base_ccy="USD" buy="17504.6894" sale="19347.2882"/>
	</exchangerates>

</exchangerates_AndriyKravets>'

-- Creating a handler of internal xml document representation
DECLARE @xmlhandle INT
EXEC sp_xml_preparedocument @xmlhandle OUTPUT, @my_xml

-- Checking if the hanlder was created
SELECT * FROM sys.dm_exec_xml_handles (0)

-- Mapping our XML to table
SELECT * FROM OPENXML(@xmlhandle, 'exchangerates_AndriyKravets/exchangerates/exchangerate', 2)
WITH (
	ccy varchar(3) '@ccy',
	base_ccy varchar(3) '@base_ccy',
	buy float '@buy',
	sale float '@sale'
	);

-- Releasing resources and checking
EXEC sp_xml_removedocument @xmlhandle
SELECT * FROM sys.dm_exec_xml_handles (0)


/*
SQL partitions
1. Create your own partitions in database (NameSurname_ParititionDB), partition function, scheme and table.
*/

-- I will switch to new db
USE AndriyKravets_ParititionDB
GO

-- Then I will create filegroups
ALTER DATABASE AndriyKravets_ParititionDB
ADD FILEGROUP mytf1;  
GO  
ALTER DATABASE AndriyKravets_ParititionDB
ADD FILEGROUP mytf2;  
GO  
ALTER DATABASE AndriyKravets_ParititionDB 
ADD FILEGROUP mytf3;  
GO  
ALTER DATABASE AndriyKravets_ParititionDB 
ADD FILEGROUP mytf4;  
GO

-- After that I'll add a new file for each filegroup 
ALTER DATABASE AndriyKravets_ParititionDB 
ADD FILE   
(  
    NAME = mytf1,  
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\mytf1.ndf'  
)  
TO FILEGROUP mytf1;  
ALTER DATABASE AndriyKravets_ParititionDB  
ADD FILE   
(  
    NAME = mytf2,  
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\mytf2.ndf' 
)  
TO FILEGROUP mytf2;  
GO  
ALTER DATABASE AndriyKravets_ParititionDB   
ADD FILE   
(  
    NAME = mytf3,  
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\mytf3.ndf' 
)  
TO FILEGROUP mytf3;  
GO 
ALTER DATABASE AndriyKravets_ParititionDB   
ADD FILE   
(  
    NAME = mytf4,  
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\mytf4.ndf' 
)  
TO FILEGROUP mytf4;  
GO

-- Now let's create a partition function
CREATE PARTITION FUNCTION myPartitionFunction1 (DATE)  
    AS RANGE LEFT FOR VALUES ('1900-01-01', '2000-01-01', '2020-01-01') ;  
GO  

-- Creating our partition scheme  
CREATE PARTITION SCHEME myPartitionScheme
    AS PARTITION myPartitionFunction1  
    TO (mytf1, mytf2, mytf3, mytf4) ;  
GO  

-- Let's create new table and check  
CREATE TABLE PartitionTable (myDate DATE PRIMARY KEY, holidayName VARCHAR(124))  
    ON myPartitionScheme (myDate) ;  
GO  

-- Inserting test data
INSERT INTO PartitionTable (myDate, holidayName)
VALUES ('1812-06-18', 'War of 1812'),
	('1945-05-08', 'End of the WWII'),
	('2004-11-22', 'Start of the Orange Revolution'),
	('2013-11-21', 'Start of EuroMaidan'),
	('2020-11-13', 'Start of the EPAM DWBI Winter 2020')

-- Checking partitions 
SELECT $PARTITION.myPartitionFunction1(myDate) as 'partition number', *
FROM PartitionTable
-- And it works!


/*
SQL Geography and geometry types
1. GEOMETRY = ART: draw anything using different Geometry datatypes (let your imagination run wild and enjoy this subtusk!)
*/

-- I will use my test database
USE P_STORE
GO

-- First, I'll create a new table
CREATE TABLE GeometryTask (GeometryData GEOMETRY)  
GO 

-- Now let's draw something (a face with eyes, nose and a mouth)
INSERT INTO GeometryTask (GeometryData)
VALUES 
	('Point(1 1)')
	,('Point(-1 1)')
	,('Polygon((0 0.5, -0.2 0, 0 -0.2, 0.2 0, 0 0.5))')
	,('CURVEPOLYGON(Circularstring(1 1.5, 1.5 1, 1 0.5, 0.5 1, 1 1.5))')
	,('CURVEPOLYGON(Circularstring(-1 1.5, -0.5 1, -1 0.5, -1.5 1, -1 1.5))')
	,('CURVEPOLYGON(Circularstring(-1.5 -0.5, 0.8 -1.5, 1.5 -0.2, 0 -1, -1.5 -0.5))')
	,('CURVEPOLYGON(Circularstring(3 0, 0 -3, -3 0, 0 3, 3 0))')

	-- Let's check it
SELECT GeometryData FROM GeometryTask