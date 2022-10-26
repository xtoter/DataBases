use master;
GO
IF DB_ID (N'LAB6') IS NOT NULL
DROP DATABASE LAB6;
GO 
CREATE DATABASE LAB6
ON ( NAME = LAB6_dat, FILENAME = '/var/opt/mssql/lab6.mdf', SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% )
LOG ON ( NAME = LAB6_log, FILENAME = '/var/opt/mssql/lab6.ldf', SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO

USE LAB6;
DROP TABLE IF EXISTS [Controller]
CREATE TABLE [Controller](
	ControllerID INT IDENTITY(1,1) PRIMARY KEY,
	FirstName NVARCHAR(60) NOT NULL CHECK (LEN(FirstName) > 1),
	MiddleName NVARCHAR(60) NOT NULL CHECK (LEN(MiddleName) > 1),
	SecondName NVARCHAR(60) NOT NULL CHECK (LEN(SecondName) > 1),
	PhoneNumber NVARCHAR(60) NOT NULL CHECK (LEN(PhoneNumber) > 10),
	Schedule NVARCHAR(60) NOT NULL CHECK (LEN(Schedule) > 6),
	DateOfBirth Date CHECK (DateOfBirth < DATEADD(year, -12, GETDATE())) DEFAULT DATEADD(year, -12, GETDATE())
)


INSERT INTO [Controller] (FirstName,MiddleName,SecondName, PhoneNumber,Schedule,DateOfBirth) VALUES
(N'Alexey',' Zaharov','Olegovich','79806664728','Monday', '1999-12-06')

DROP TABLE IF EXISTS Venicle

CREATE TABLE Venicle(
    VenicleID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT(NEWID()),
    NumberPlate NVARCHAR(10) NOT NULL,
    Brand NVARCHAR(50),
    ManufactureYear INT NOT NULL,
    Capacity INT NOT NULL,
    MaximumSpeed INT,
)

INSERT INTO Venicle(NumberPlate, ManufactureYear,Capacity) VALUES
('VO879Y',1999,15)

DROP SEQUENCE IF EXISTS Posledovatelnost 

CREATE SEQUENCE Posledovatelnost 
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 10

DROP TABLE IF EXISTS Driver
CREATE TABLE Driver(
	DriverID INT PRIMARY KEY,
	FirstName NVARCHAR(60) NOT NULL CHECK (LEN(FirstName) > 1),
	MiddleName NVARCHAR(60) NOT NULL CHECK (LEN(MiddleName) > 1),
	SecondName NVARCHAR(60) NOT NULL CHECK (LEN(SecondName) > 1),
	PhoneNumber NVARCHAR(60) NOT NULL CHECK (LEN(PhoneNumber) > 10),
	Schedule NVARCHAR(60) NOT NULL CHECK (LEN(Schedule) > 6),
	DriversLicenseDate Date NOT NULL,
	DateOfBirth Date CHECK (DateOfBirth < DATEADD(year, -12, GETDATE())) DEFAULT DATEADD(year, -12, GETDATE())
)
INSERT INTO Driver(DriverID,FirstName,MiddleName,SecondName, PhoneNumber,Schedule,DriversLicenseDate,DateOfBirth) VALUES
(NEXT VALUE FOR Posledovatelnost,'Alexey',' Zaharov','Olegovich','79806464528','Monday','2019-10-06', '1999-12-06'),
(NEXT VALUE FOR Posledovatelnost,'Oleg',' Zheka','Dmitriewich','79809024728','Monday','2019-10-06', '1999-12-06')


DROP TABLE IF EXISTS Route 
	CREATE TABLE Route
	(RouteNumber int PRIMARY KEY,
	RouteName varchar(30),
	Price INT,
	);

DROP TABLE IF EXISTS ControllersOffice

CREATE TABLE ControllersOffice
(OfficeID int PRIMARY KEY IDENTITY(1,1),
Address varchar(30),
PhoneNumber varchar(30),
Mail varchar(30),
Fax varchar(30),
Schedule varchar(30),
RouteNumber INT,
CONSTRAINT FK_RouteNumber FOREIGN KEY (RouteNumber) REFERENCES Route (RouteNumber)
	ON UPDATE CASCADE --каскадное изменение ссылающихся таблиц;
	--ON UPDATE NO ACTION --выдаст ошибку при удалении/изменении
	--ON UPDATE SET NULL --установка NULL для ссылающихся внешних ключей;
	--ON UPDATE SET DEFAULT --установка значений по умолчанию для ссылающихся внешних ключей;
	ON DELETE SET NULL
    --ON DELETE NO ACTION
    --ON DELETE SET DEFAULT
    --ON DELETE CASCADE
);

INSERT INTO Route(RouteNumber,RouteName, Price) VALUES
(1,'vokzal', 30), (2,'airport', 20)
INSERT INTO ControllersOffice(Address,PhoneNumber ,RouteNumber) VALUES
('ul Puskina 5','88005553535', 1),('ul Puskina 9','88005533535', 2)
Select *from ControllersOffice;
	UPDATE Route
	SET RouteNumber = 3
	WHERE RouteNumber = 2
Select *from ControllersOffice;
Select *from Route;

DELETE FROM Route WHERE RouteNumber=1
	
