USE LAB6
GO
if OBJECT_ID(N'office_and_route', N'V') is not null
	drop view office_and_route;
go
create view office_and_route as
	select 
		office.Address as name, 
		rout.RouteName as route,
		rout.RouteNumber as num,
		office.OfficeID as officeid
	from ControllersOffice office 
	inner join Route rout
		on office.OfficeID  = rout.OfficeID;
go
--Для одной из таблиц пункта 2 задания 7 создать
--триггеры на вставку, удаление и добавление, при
--выполнении заданных условий один из триггеров
--должен инициировать возникновение ошибки
--(RAISERROR / THROW).
if OBJECT_ID(N'dbo.Route_trigger_insert', N'TR') is not null
	drop trigger dbo.Route_trigger_insert
go
create trigger dbo.Route_trigger_insert
	on dbo.Route
	for insert
	as
		if exists (select *
			from inserted
			where inserted.RouteNumber < 1)
			RAISERROR('[insert]: Bad Numberr', 10, 1);
go


--trigger on UPDATE
if OBJECT_ID(N'dbo.Route_trigger_update', N'TR') is not null
	drop trigger dbo.Route_trigger_update
go
create trigger dbo.Route_trigger_update
	on dbo.Route
	for update
	as
		print '[update]: table dbo.Route has been updated'
go


--trigger on DELETE
if OBJECT_ID(N'dbo.Route_trigger_delete', N'TR') is not null
	drop trigger dbo.Route_trigger_delete
go
create trigger dbo.Route_trigger_delete
	on dbo.Route
	instead of delete
	as
		if (select count(*) from dbo.Route) > 1
		begin
			DELETE FROM Route WHERE RouteNumber IN (SELECT RouteNumber FROM deleted)
			
		end
go
--INSERT INTO Route(RouteNumber,RouteName, Price) VALUES
--(0,'vokzal', 26), (4,'airport', 40)
--delete from dbo.Route where RouteNumber > 25;
--select * from dbo.Route;



--Для представления пункта 2 задания 7 создать
--триггеры на вставку, удаление и добавление,
--обеспечивающие возможность выполнения
--операций с данными непосредственно через
--представление.
IF DB_ID (N'LAB66') IS NOT NULL
DROP DATABASE LAB66;
GO 
CREATE DATABASE LAB66
ON ( NAME = LAB6_dat, FILENAME = '/var/opt/mssql/lab66.mdf', SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% )
LOG ON ( NAME = LAB6_log, FILENAME = '/var/opt/mssql/lab66.ldf', SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO

USE LAB66;
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
DROP TABLE IF EXISTS Route 
GO
	CREATE TABLE Route
	(RouteNumber int PRIMARY KEY,
	RouteName varchar(30),
	Price INT,
	OfficeID int,
	CONSTRAINT FK_OfficeID FOREIGN KEY (OfficeID) REFERENCES ControllersOffice (OfficeID)
	);

if OBJECT_ID(N'office_and_route', N'V') is not null
	drop view office_and_route;
go
create view office_and_route as
	select 
		office.Address as name, 
		rout.RouteName as route,
		rout.RouteNumber as num,
		office.PhoneNumber as phone,
		office.Mail as mail
	from ControllersOffice office 
	inner join Route rout
		on office.OfficeID  = rout.OfficeID;
go


if OBJECT_ID(N'dbo.office_and_route_trigger_insert', N'TR') is not null
	drop trigger dbo.office_and_route_trigger_insert
go

create trigger dbo.office_and_route_trigger_insert
	on dbo.office_and_route
	instead of insert
	as
	begin
		   
    	
		INSERT INTO ControllersOffice(Address,PhoneNumber,Mail) SELECT DISTINCT i.name,i.phone,i.mail FROM inserted as i WHERE i.name not in  (SELECT Address FROM ControllersOffice as c WHERE c.Address = i.name)
		INSERT INTO Route(OfficeID,RouteNumber,RouteName) SELECT c.OfficeID,i.num,i.route  FROM inserted i, ControllersOffice  c WHERE c.Address = i.name
	end
go
INSERT INTO office_and_route(name,route,num,phone,mail) VALUES
('pyskina 98','bus station51',14852311,'+79993829344','noreply@rzd.ru'),
('pyskina 98','bus station61',14853322,'+79993829344','noreply@rzd.ru'),
('pyskina 98','bus station71',14854333,'+79993829344','noreply@rzd.ru')
GO
select * from ControllersOffice
GO
select * from Route
--del
if OBJECT_ID(N'dbo.office_and_route_trigger_delete', N'TR') is not null
	drop trigger dbo.office_and_route_trigger_delete
go

create trigger dbo.office_and_route_trigger_delete
	on dbo.office_and_route
	instead of delete
	as
	begin
		DELETE FROM Route WHERE RouteNumber IN (SELECT num FROM deleted)
	end
go
--delete from dbo.office_and_route where num = 44

-- UPDATE 
if OBJECT_ID(N'dbo.office_and_route_trigger_update', N'TR') is not null
	drop trigger dbo.office_and_route_trigger_update
go
create trigger dbo.office_and_route_trigger_update
	on dbo.office_and_route
	instead of update
	as 
	begin

		if UPDATE(num) or UPDATE(name) 
			RAISERROR('[UPDATE TRIGGER]: num and name cant be modified', 16, 1)

		if UPDATE(route)
		 UPDATE Route SET RouteName=i.route FROM Route p INNER JOIN inserted i ON (i.num=p.RouteNumber)
			
	end
go
select * from dbo.office_and_route
go
--update dbo.office_and_route 
--	set route = 'bus statio88'
--	where office_and_route.route = 'bus statio2';

