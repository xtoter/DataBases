

use master;
go

DROP DATABASE IF EXISTS lab10
go

CREATE DATABASE lab10
on (
	NAME = lab10dat,
	FILENAME = '/var/opt/mssql/lab10.mdf',
	SIZE = 10,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5
)
log on (
	NAME = lab10log,
	FILENAME = '/var/opt/mssql/lab10.ldf',
	SIZE = 5,
	MAXSIZE = 20,
	FILEGROWTH = 5
);
go 

use lab10;
go 

DROP TABLE IF EXISTS [Controller]
CREATE TABLE [Controller](
	ControllerID INT IDENTITY(1,1) PRIMARY KEY,
	FirstName NVARCHAR(60) NOT NULL CHECK (LEN(FirstName) > 1),
	MiddleName NVARCHAR(60) NOT NULL CHECK (LEN(MiddleName) > 1),
	SecondName NVARCHAR(60) NOT NULL CHECK (LEN(SecondName) > 1),
	PhoneNumber NVARCHAR(60) NOT NULL CHECK (LEN(PhoneNumber) > 10),
	Schedule NVARCHAR(60) NOT NULL CHECK (LEN(Schedule) > 5),
	DateOfBirth Date CHECK (DateOfBirth < DATEADD(year, -12, GETDATE())) DEFAULT DATEADD(year, -12, GETDATE())
)




DELETE FROM [Controller]

INSERT INTO [Controller] (FirstName,MiddleName,SecondName, PhoneNumber,Schedule,DateOfBirth) VALUES
(N'Alexey',' Zaharov','Olegovich','79806664728','Monday', '1999-12-06')

SELECT * FROM [Controller]