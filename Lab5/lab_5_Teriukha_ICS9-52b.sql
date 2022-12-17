USE [master]
GO
IF DB_ID (N'Controller') IS NOT NULL
DROP DATABASE Controller;
GO

CREATE DATABASE Controller
ON PRIMARY
(
	NAME = Controller_PrimaryData,
	FILENAME = '/var/opt/mssql/Controller_db.mdf', 
	SIZE = 10,
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 5%
),
(
	NAME = Controller_SecondaryData,
	FILENAME = '/var/opt/mssql/Controller_db1.ndf' 
)
LOG ON
(
	NAME = Controller_Log,
	FILENAME = '/var/opt/mssql/Controller_log.ldf',
	SIZE = 5MB,
	MAXSIZE = 25MB,
	FILEGROWTH = 5%
)
GO

USE Controller
GO

CREATE TABLE ControllerTable(
	ControllerID INT NOT NULL,
	FirstName NVARCHAR(60) NOT NULL,
	MiddleName NVARCHAR(60) NOT NULL,
	SecondName NVARCHAR(60) NOT NULL,
	PhoneNumber NVARCHAR(60) NOT NULL,
	Schedule NVARCHAR(60) NOT NULL,
	DateOfBirth Date
) 
GO

ALTER DATABASE Controller
ADD FILEGROUP LargeFileGroup;  
GO

ALTER DATABASE Controller
ADD FILE(
    NAME = Controller_LargeData,  
    FILENAME = '/var/opt/mssql/Controller_db2.ndf',  
    SIZE = 5MB,  
    MAXSIZE = 25MB,  
    FILEGROWTH = 5% 
)
TO FILEGROUP LargeFileGroup
GO

ALTER DATABASE Controller 
  MODIFY FILEGROUP LargeFileGroup DEFAULT;
GO

CREATE TABLE Route(
    RouteNumber int NOT NULL,
    RouteName char(100) NOT NULL,
    Price int NOT NULL
)
GO

DROP TABLE Route;
GO

ALTER DATABASE Controller
  MODIFY FILEGROUP [primary] DEFAULT;
GO

ALTER DATABASE Controller  
REMOVE FILE Controller_LargeData;  
GO 

ALTER DATABASE Controller  
REMOVE FILEGROUP LargeFileGroup ;  
GO 

CREATE SCHEMA Schema1;
GO

ALTER SCHEMA Schema1 TRANSFER dbo.ControllerTable; 
GO

DROP TABLE Schema1.ControllerTable; 
GO

DROP SCHEMA Schema1;
GO
