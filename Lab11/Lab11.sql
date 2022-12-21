use master;
go

DROP DATABASE IF EXISTS lab11
go

CREATE DATABASE lab11
on (
	NAME = lab11dat,
	FILENAME = '/var/opt/mssql/lab11.mdf',
	SIZE = 10,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5
)
log on (
	NAME = lab11log,
	FILENAME = '/var/opt/mssql/lab11.ldf',
	SIZE = 5,
	MAXSIZE = 20,
	FILEGROWTH = 5
);
go 

use lab11;
go 
DROP SEQUENCE IF EXISTS UserID
CREATE SEQUENCE UserID
	START WITH 1
    INCREMENT BY 1
go
    
DROP TABLE IF EXISTS ControllersOffice
CREATE TABLE ControllersOffice(
    OfficeId INT  IDENTITY(1,1) PRIMARY KEY,
    Schedule VARCHAR(30) ,
    Address VARCHAR(30) UNIQUE NOT NULL,
    PhoneNumber VARCHAR(30) UNIQUE NOT NULL,
    Mail VARCHAR(30) ,
    Fax VARCHAR(30)
)

GO
DROP TABLE IF EXISTS Controller
CREATE TABLE Controller(
    id INT PRIMARY KEY,
    PassportData VARCHAR(30) UNIQUE NOT NULL,
    FirstName VARCHAR(30) ,
    SecondName VARCHAR(30) ,
    MiddleName VARCHAR(30) ,
    DateofBirth date default GETDATE(),
    Schedule VARCHAR(30) ,
    PhoneNumber VARCHAR(30) UNIQUE NOT NULL
)

GO
DROP TABLE IF EXISTS Driver
CREATE TABLE Driver(
    id INT PRIMARY KEY,
    PassportData VARCHAR(30) UNIQUE NOT NULL,
    FirstName VARCHAR(30) ,
    SecondName VARCHAR(30) ,
    MiddleName VARCHAR(30) ,
    DateofBirth date default GETDATE(),
    Schedule VARCHAR(30) ,
    PhoneNumber VARCHAR(30) UNIQUE NOT NULL,
    DriverLicenseDate date  NOT NULL
)
GO
DROP TABLE IF EXISTS Venicle
CREATE TABLE Venicle(
    NumberPlate VARCHAR(30) PRIMARY KEY,
    Brand VARCHAR(30) ,
    ManufactureYear INT ,
    Capacity INT NOT NULL,
    MaximumSpeed INT CHECK (MaximumSpeed>=60)
)
GO

DROP TABLE IF EXISTS Route
CREATE TABLE Route(
    RouteNumber INT IDENTITY(1,1)  PRIMARY KEY,
    Price INT NOT NULL,
    RouteName VARCHAR(30) UNIQUE NOT NULL,
    ControllerId INT,
    OfficeID INT,
	CONSTRAINT OfficeIDFK FOREIGN KEY (OfficeID) REFERENCES ControllersOffice(OfficeId) on DELETE CASCADE,
	CONSTRAINT ControllerIdFK FOREIGN KEY (ControllerId) REFERENCES Controller(id) on DELETE CASCADE,
)

GO
DROP TABLE IF EXISTS WayBill
CREATE TABLE WayBill(
    id INT IDENTITY(1,1) PRIMARY KEY,
    Routeid INT ,
    DepartureTime VARCHAR(30),
    VenicleID VARCHAR(30),
    DriverID INT,
    DaysofWeek VARCHAR(30),
	CONSTRAINT RouteidFK FOREIGN KEY (Routeid) REFERENCES Route(RouteNumber) on DELETE CASCADE,
	CONSTRAINT DriverIDFK FOREIGN KEY (DriverID) REFERENCES Driver(id) on DELETE CASCADE,
	CONSTRAINT VenicleIDFK FOREIGN KEY (VenicleID) REFERENCES Venicle(NumberPlate) on DELETE CASCADE,
)
GO
----
INSERT INTO ControllersOffice (Schedule,Address, PhoneNumber,Mail,Fax) VALUES
('Monday','Pyshkina 40','9996339283','noraply@noreply.com','nope'),
('Saturday','Pyshkina 45','79946339283','noreply@noreply.com','nope')

DECLARE @officeId INT
SET @officeId=SCOPE_IDENTITY()
INSERT INTO Controller (id,PassportData,PhoneNumber) VALUES
((NEXT VALUE FOR UserID),'nodata','no'),
((NEXT VALUE FOR UserID),'Saturday','da')
INSERT INTO Driver (id,PassportData,PhoneNumber,DriverLicenseDate) VALUES
((NEXT VALUE FOR UserID),'nodata','da',GETDATE()),
((NEXT VALUE FOR UserID),'Saturday','no',GETDATE())

INSERT INTO Venicle (NumberPlate,MaximumSpeed,Capacity) VALUES
('abba',90,5),
('dada',100,55)
INSERT INTO Route (ControllerId,OfficeID,RouteName,price) VALUES
(1,@officeId,'airport',1),
(2,@officeId,'kazanskaya',2)
DECLARE @Routeid INT
SET @Routeid =  SCOPE_IDENTITY()
INSERT INTO WayBill (Routeid,DriverID,VenicleID) VALUES
(@Routeid ,3,'abba'),
(@Routeid ,4,'dada')

GO

SELECT * FROM ControllersOffice
GO
SELECT * FROM Controller
GO
SELECT * FROM Driver
GO
SELECT * FROM Venicle
GO
SELECT * FROM Route
GO
SELECT * FROM WayBill

GO
DROP VIEW IF EXISTS AllPeople
GO
CREATE VIEW AllPeople AS 
SELECT 'Controller' AS jobtitle,a.id ,a.PassportData ,a.FirstName ,a.SecondName ,a.MiddleName ,a.DateofBirth ,a.Schedule ,a.PhoneNumber, NULL as DriverLicenseDate  FROM Controller as a
UNION ALL
SELECT 'Driver' AS jobtitle,a.id ,a.PassportData ,a.FirstName ,a.SecondName ,a.MiddleName ,a.DateofBirth ,a.Schedule ,a.PhoneNumber ,a.DriverLicenseDate FROM Driver as a
GO
Select * FROM AllPeople

GO
DROP TRIGGER IF EXISTS UpdatePeople
GO
CREATE TRIGGER UpdatePeople ON AllPeople
INSTEAD OF UPDATE
AS
BEGIN
	
   	if (UPDATE(jobtitle))BEGIN
   		RAISERROR('ERROR OPERATION',-1,11)
   	END
   	
  	IF (UPDATE(id))BEGIN
           RAISERROR('bad operation',-1,11)
    END
    IF (EXISTS (SELECT id FROM inserted WHERE id IN (SELECT id FROM Controller)))BEGIN
        UPDATE Controller SET PassportData=i.PassportData ,FirstName=i.FirstName ,SecondName=i.SecondName ,MiddleName=i.MiddleName ,DateofBirth=i.DateofBirth ,Schedule=i.Schedule ,PhoneNumber=i.PhoneNumber  FROM Controller b INNER JOIN inserted i ON i.id=b.id
	    PRINT N'Controller Update';  
	END 
	IF (EXISTS (SELECT id FROM inserted WHERE id IN (SELECT id FROM Driver)))BEGIN
		UPDATE Driver SET PassportData=i.PassportData ,FirstName=i.FirstName ,SecondName=i.SecondName ,MiddleName=i.MiddleName ,DateofBirth=i.DateofBirth ,Schedule=i.Schedule ,PhoneNumber=i.PhoneNumber  FROM Driver b INNER JOIN inserted i ON i.id=b.id
             PRINT N'Driver Update';  
	END 
END
update AllPeople
	set FirstName = 'axaxa'
	where id = 3
	
GO 
DROP TRIGGER IF EXISTS INSERTPeople

GO
CREATE TRIGGER INSERTPeople ON AllPeople
INSTEAD OF INSERT
AS
BEGIN
	
   	if (EXISTS (SELECT jobtitle FROM inserted WHERE jobtitle = 'Driver'))BEGIN
	  	INSERT INTO Driver SELECT id ,PassportData ,FirstName,SecondName,MiddleName,DateofBirth ,Schedule ,PhoneNumber,DriverLicenseDate  FROM inserted WHERE jobtitle = 'Driver'
		PRINT N'Driver INSERT'; 
   	END
   	if (EXISTS (SELECT jobtitle FROM inserted WHERE jobtitle = 'Controller'))BEGIN
	   	INSERT INTO Controller SELECT id ,PassportData ,FirstName,SecondName,MiddleName,DateofBirth ,Schedule ,PhoneNumber  FROM inserted WHERE jobtitle = 'Controller'
   		 PRINT N'Controller INSERT'; 
   	END
  --  UPDATE Route SET RouteName=i.RouteName,Price=i.Price FROM Route b INNER JOIN inserted i ON i.RouteNumber=b.RouteNumber
END
GO
INSERT INTO AllPeople (jobtitle,id,PassportData,PhoneNumber,DriverLicenseDate) VALUES
('Controller',(NEXT VALUE FOR UserID),'PassportData1','+79004859942',NULL),
('Controller',(NEXT VALUE FOR UserID),'PassportData2','+79004859941',NULL),
('Driver',(NEXT VALUE FOR UserID),'PassportData3','+79004859977',GETDATE())

GO 
DROP TRIGGER IF EXISTS DeletePeople

GO
CREATE TRIGGER DeletePeople ON AllPeople
INSTEAD OF Delete
AS
BEGIN
	DELETE b FROM Controller AS b INNER JOIN deleted AS D ON d.id=b.id
	DELETE b FROM Driver AS b INNER JOIN deleted AS D ON d.id=b.id 
  
  --  UPDATE Route SET RouteName=i.RouteName,Price=i.Price FROM Route b INNER JOIN inserted i ON i.RouteNumber=b.RouteNumber
END
--delete AllPeople
--where id = 2
GO 
DROP FUNCTION IF EXISTS dbo.getDriverId
GO
CREATE FUNCTION getDriverId(@PassportData VARCHAR(30)) RETURNS INT
BEGIN
    RETURN (SELECT id FROM Driver WHERE Driver.PassportData=@PassportData)
END
GO
DROP PROCEDURE IF EXISTS addWaybill
GO
CREATE PROCEDURE addWaybill(@Routeid INT ,@DepartureTime VARCHAR(30),@VenicleID VARCHAR(30),@PassportData VARCHAR(30),@DaysofWeek VARCHAR(30)) AS
BEGIN
    DECLARE @Id INT
    SET @Id=dbo.getDriverId(@PassportData)
    if (@id is not null AND (EXISTS (SELECT RouteNumber FROM Route WHERE RouteNumber = @Routeid)) AND (EXISTS (SELECT NumberPlate FROM Venicle WHERE NumberPlate = @VenicleID))) BEGIN
 		Print 'create waybill'
 		INSERT INTO waybill(Routeid ,DepartureTime,VenicleID,DriverID,DaysofWeek)
    	VALUES (@Routeid ,@DepartureTime,@VenicleID,@Id,@DaysofWeek)
	END
    --INSERT INTO BATCH(shopId,productId,price,number)
    --VALUES (@shopId,@productId,@price,@number)
END
GO
EXECUTE addWaybill 1,'12-00','abba','PassportData3','test'
GO
--DISTINCT
SELECT DISTINCT VenicleID 
FROM WayBill
--LEFT JOIN
GO
SELECT *
FROM ControllersOffice LEFT JOIN Route
ON ControllersOffice.OfficeId  = Route.OfficeID 
GO
--RIGHT JOIN

SELECT *
FROM Waybill RIGHT JOIN Route
ON Waybill.Routeid  = Route.RouteNumber  ORDER BY DepartureTime ASC
GO
--OUTER JOIN 
SELECT *
FROM Route FULL OUTER JOIN  Controller
ON Controller.id  = Route.ControllerId  ORDER BY Price DESC
GO
DROP PROCEDURE IF EXISTS PeopleBetween
GO
CREATE PROCEDURE PeopleBetween(@a date ,@b date)AS
BEGIN
	SELECT *
		FROM AllPeople WHERE AllPeople.DateofBirth  BETWEEN @a AND @b
	
END

EXECUTE PeopleBetween '2008-11-11' , '2028-11-11'
--
GO
DROP PROCEDURE IF EXISTS WaybillinDay
GO
CREATE PROCEDURE WaybillinDay(@a  VARCHAR(30))AS
BEGIN
	SELECT *
		FROM WayBill  WHERE WayBill.DaysofWeek LIKE '%'+@a+'%'
END
EXECUTE WaybillinDay 'Sunday'

GO
SELECT RouteID ,  COUNT(*) as count, SUM(Capacity) as sumCapacity , AVG(Capacity) as avgCapacity,MIN(Capacity) as minCapacity,MAX(Capacity) as maxCapacity
FROM WayBill INNER JOIN Venicle
ON Waybill.VenicleID =Venicle.NumberPlate GROUP BY RouteID HAVING  COUNT(*)  > 0


GO
DROP PROCEDURE IF EXISTS WaybillinWeekend
GO
CREATE PROCEDURE WaybillinWeekend AS
BEGIN
	SELECT *
		FROM WayBill  WHERE WayBill.DaysofWeek LIKE '%Sunday%'
		UNION 
	SELECT *
		FROM WayBill  WHERE WayBill.DaysofWeek LIKE '%Saturday%'
END
GO
EXECUTE WaybillinWeekend
GO
DROP PROCEDURE IF EXISTS WaybillALLWeekend
GO
CREATE PROCEDURE WaybillALLWeekend AS
BEGIN
	SELECT *
		FROM WayBill as w WHERE w.DaysofWeek LIKE '%Sunday%'
		INTERSECT 
	SELECT *
		FROM WayBill as w  WHERE w.DaysofWeek LIKE '%Saturday%'
END
GO
EXECUTE WaybillALLWeekend
GO
DROP PROCEDURE IF EXISTS Waybillonlyweekdays
GO
CREATE PROCEDURE Waybillonlyweekdays AS
BEGIN
	SELECT *
		FROM WayBill
	Except
	(SELECT *
		FROM WayBill as w WHERE w.DaysofWeek LIKE '%Sunday%'
		UNION 
	SELECT *
		FROM WayBill as w  WHERE w.DaysofWeek LIKE '%Saturday%')
END
GO
EXECUTE Waybillonlyweekdays
GO

