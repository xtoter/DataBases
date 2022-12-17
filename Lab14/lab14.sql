--1.Создать две базы данных на одном экземпляре СУБД SQL Server 2012.
use master;
go
if DB_ID (N'lab14a') is not null
	drop database lab14a;
go
create database lab14a
go


use master;
go
if DB_ID (N'lab14b') is not null
	drop database lab14b;
go
create database lab14b
go



--2.Создать в базах данных п.1. горизонтально фрагментированные таблицы.
use lab14a;
go
if OBJECT_ID(N'dbo.Venicle', N'U') is not null
    drop table dbo.Venicle;
go
CREATE TABLE Venicle(
    VenicleID INT PRIMARY KEY,
    NumberPlate NVARCHAR(10) NOT NULL,
    --Brand NVARCHAR(50),
    --ManufactureYear INT NOT NULL,
    --Capacity INT NOT NULL,
    MaximumSpeed INT,
  
)
go


use lab14b;
go
if OBJECT_ID(N'dbo.Venicle', N'U') is not null
    drop table dbo.Venicle;
go
CREATE TABLE Venicle(
    VenicleID INT PRIMARY KEY,
    --NumberPlate NVARCHAR(10) NOT NULL,
    Brand NVARCHAR(50),
    ManufactureYear INT NOT NULL,
    Capacity INT NOT NULL,
    --MaximumSpeed INT,
    
)
go

CREATE VIEW verticalal_dist_v AS
    SELECT a.VenicleID,a.NumberPlate,b.Brand,b.ManufactureYear,b.Capacity,a.MaximumSpeed FROM
    LAB14a.dbo.Venicle AS a, 
    LAB14b.dbo.Venicle as b
    WHERE a.VenicleID=b.VenicleID
GO
SELECT * from verticalal_dist_v

DROP TRIGGER IF EXISTS InsertVenicle

GO

CREATE TRIGGER InsertVenicle ON verticalal_dist_v
INSTEAD OF INSERT
AS
BEGIN
    IF (EXISTS (SELECT VenicleID FROM LAB14a.dbo.Venicle INTERSECT SELECT VenicleID FROM inserted)) BEGIN
        RAISERROR('Rewriting',-1,11)
    END

    INSERT INTO LAB14a.dbo.Venicle SELECT VenicleID,NumberPlate,MaximumSpeed FROM inserted
    INSERT INTO LAB14b.dbo.Venicle SELECT VenicleID,Brand,ManufactureYear,Capacity FROM inserted
END
GO

DROP TRIGGER IF EXISTS DeleteVenicle

GO

CREATE TRIGGER DeleteVenicle ON verticalal_dist_v
INSTEAD OF DELETE
AS
BEGIN
    DELETE a FROM  LAB14a.dbo.Venicle AS a INNER JOIN deleted AS b ON a.VenicleID=b.VenicleID
    DELETE a FROM  LAB14b.dbo.Venicle AS a INNER JOIN deleted AS b ON a.VenicleID=b.VenicleID
END
GO

DROP TRIGGER IF EXISTS UpdateVenicle

GO

CREATE TRIGGER UpdateVenicle ON verticalal_dist_v
INSTEAD OF UPDATE
AS
BEGIN
    IF UPDATE(ManufactureYear) BEGIN
        RAISERROR('Wrong update',-1,11)
    END

    UPDATE LAB14a.dbo.Venicle SET VenicleID=i.VenicleID,NumberPlate=i.NumberPlate,MaximumSpeed=i.MaximumSpeed FROM LAB14a.dbo.Venicle a INNER JOIN inserted i ON a.VenicleID=i.VenicleID
    UPDATE LAB14b.dbo.Venicle SET VenicleID=i.VenicleID,Brand=i.Brand,Capacity=i.Capacity FROM LAB14b.dbo.Venicle a INNER JOIN inserted i ON a.VenicleID=i.VenicleID
END
GO

INSERT INTO verticalal_dist_v VALUES 
	(1,'VO879Y','VAZ',1999,40,15),
	(3,'V1179Y','YAZ',1929,40,15)
SELECT * FROM verticalal_dist_v

DELETE FROM verticalal_dist_v WHERE VenicleID=1

SELECT * FROM verticalal_dist_v

UPDATE verticalal_dist_v SET ManufactureYear=0 WHERE Brand='V1179Y'

SELECT * FROM verticalal_dist_v
