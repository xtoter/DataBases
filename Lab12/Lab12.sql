use master;
GO
IF DB_ID (N'LAB12') IS NOT NULL
DROP DATABASE LAB12;
GO 
CREATE DATABASE LAB12
ON ( NAME = LAB12_dat, FILENAME = '/var/opt/mssql/lab12.mdf', SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% )
LOG ON ( NAME = LAB12_log, FILENAME = '/var/opt/mssql/lab12.ldf', SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO

USE LAB12;
GO
DROP TABLE IF EXISTS ControllersOffice 
GO
CREATE TABLE ControllersOffice
	(OfficeID int PRIMARY KEY IDENTITY(1,1),
	Address varchar(30) NOT NULL UNIQUE,
	PhoneNumber varchar(30),
	Mail varchar(30),
	Fax varchar(30),
	Schedule varchar(30),

);
GO
INSERT INTO ControllersOffice(Address,PhoneNumber,Mail,Schedule) VALUES
('pyskina 93','+79993829344','noreply@rzd.ru','Monday'),
('pyskina 94','+79993829344','noreply@rzd.ru','Monday'),
('pyskina 95','+79993829344','noreply@rzd.ru','Monday')
GO
select * from ControllersOffice
GO