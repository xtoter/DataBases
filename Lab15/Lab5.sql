--1.Создать две базы данных на одном экземпляре СУБД SQL Server 2012.
use master;
go
if DB_ID (N'lab15a') is not null
	drop database lab15a;
go
create database lab15a
go


use master;
go
if DB_ID (N'lab15b') is not null
	drop database lab15b;
go
create database lab15b
go



--2.Создать в базах данных п.1. горизонтально фрагментированные таблицы.
use lab15a;
go
DROP TABLE IF EXISTS ControllersOffice 
go
CREATE TABLE ControllersOffice
(OfficeID int PRIMARY KEY,
Address varchar(30),
PhoneNumber varchar(30),
Mail varchar(30),
Fax varchar(30),
Schedule varchar(30),
);
go


use lab15b;
go

DROP TABLE IF EXISTS Route 
go;
	CREATE TABLE Route
	(RouteNumber int PRIMARY KEY,
	RouteName varchar(30),
	Price INT,
	OfficeID int
	);

go
INSERT INTO lab15b.dbo.Route VALUES 
(2,'axaxa 2',3,2),(3,'axaxa 3',3,2),(4,'axaxa 4',3,1)


--3.Создать секционированные представления, обеспечивающие работу с данными таблиц 
	--(выборку, вставку, изменение, удаление).
use lab15a;
go
if OBJECT_ID(N'RouteAndOffice', N'V') is not null
	drop view RouteAndOffice;
go
create view RouteAndOffice as
	select a.OfficeID ,a.Address ,a.PhoneNumber , a.Mail ,a.Fax ,a.Schedule ,
	b.RouteNumber ,b.RouteName ,b.Price FROM lab15a.dbo.ControllersOffice a, lab15b.dbo.Route b WHERE a.OfficeID = b.OfficeID
go


DROP TRIGGER IF EXISTS OfficeInsert
GO

CREATE TRIGGER OfficeInsert ON ControllersOffice
INSTEAD OF INSERT
AS
BEGIN
    IF (EXISTS (SELECT OfficeID from inserted WHERE OfficeID NOT IN (SELECT OfficeID FROM lab15a.dbo.ControllersOffice))) BEGIN
        RAISERROR('Wrong FK',-1,11)
    END
    INSERT INTO ControllersOffice SELECT * FROM inserted
END
GO
INSERT INTO lab15a.dbo.ControllersOffice VALUES 
(2,'axaxa 2','net','ddddd','ddddd','dsfgsgd')

DROP TRIGGER IF EXISTS OfficeDelete
GO
CREATE TRIGGER OfficeDelete ON ControllersOffice
INSTEAD OF DELETE
AS
BEGIN
    DELETE b FROM ControllersOffice AS b INNER JOIN deleted AS D ON d.OfficeID=b.OfficeID 
    DELETE b FROM lab15b.dbo.Route AS b INNER JOIN deleted AS D ON d.OfficeID=b.OfficeID 
END
GO

DROP TRIGGER IF EXISTS OfficeUpdate
GO

CREATE TRIGGER OfficeUpdate ON ControllersOffice
INSTEAD OF UPDATE
AS
BEGIN
    IF (UPDATE(OfficeID))BEGIN
         IF (EXISTS (SELECT OfficeID FROM inserted WHERE OfficeID NOT IN (SELECT OfficeID FROM lab15a.dbo.ControllersOffice)))BEGIN
            RAISERROR('Wrong Update',-1,11)
            END
    END
    UPDATE ControllersOffice SET Address=i.Address,PhoneNumber=i.PhoneNumber,Mail=i.Mail,Fax=i.Fax,Schedule=i.Schedule FROM ControllersOffice b INNER JOIN inserted i ON i.OfficeID=b.OfficeID
END
GO

update ControllersOffice
	set Address = 'da'
	where OfficeID = 2
	
	
-- 2 таблица

use lab15b;
go

DROP TRIGGER IF EXISTS RouteInsert
GO

CREATE TRIGGER RouteInsert ON  Route
INSTEAD OF INSERT
AS
BEGIN
    IF (EXISTS (SELECT RouteNumber from inserted WHERE RouteNumber  IN (SELECT RouteNumber FROM lab15b.dbo.Route))) BEGIN
        RAISERROR('Wrong FK, already exist',-1,11)
    END ELSE
    IF (EXISTS (SELECT OfficeID from inserted WHERE OfficeID NOT IN (SELECT OfficeID FROM lab15a.dbo.ControllersOffice))) BEGIN
        RAISERROR('Not found office',-1,11)

    END ELSE
       	INSERT INTO Route SELECT * FROM inserted
END
GO

DROP TRIGGER IF EXISTS RouteDelete
GO
CREATE TRIGGER RouteDelete ON Route
INSTEAD OF DELETE
AS
BEGIN
    DELETE b FROM lab15b.dbo.Route AS b INNER JOIN deleted AS D ON d.OfficeID=b.OfficeID 
    DELETE b FROM lab15b.dbo.Route AS b INNER JOIN deleted AS D ON d.RouteNumber=b.RouteNumber 
END
GO

DROP TRIGGER IF EXISTS RouteUpdate
GO

CREATE TRIGGER RouteUpdate ON Route
INSTEAD OF UPDATE
AS
BEGIN
	IF (UPDATE(RouteNumber))BEGIN
           RAISERROR('bad operation',-1,11)
    END else
    IF (UPDATE(OfficeID))BEGIN
         IF (EXISTS (SELECT OfficeID FROM inserted WHERE OfficeID NOT IN (SELECT OfficeID FROM lab15a.dbo.ControllersOffice)))BEGIN
            RAISERROR('bad office',-1,11)
            END else
            UPDATE Route SET OfficeID=i.OfficeID,RouteName=i.RouteName,Price=i.Price  FROM Route b INNER JOIN inserted i ON i.RouteNumber=b.RouteNumber

    END else
     
    UPDATE Route SET RouteName=i.RouteName,Price=i.Price FROM Route b INNER JOIN inserted i ON i.RouteNumber=b.RouteNumber
END
GO
update Route
	set RouteName = 'axaxa'
	where RouteNumber = 2
