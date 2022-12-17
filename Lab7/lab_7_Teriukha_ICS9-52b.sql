use LAB6;

--1.Создать представление на основе одной из таблиц задания 6.
if OBJECT_ID(N'DriverMonday', N'V') is not null
	drop view DriverMonday;
go
create view DriverMonday as 
	select *
	from Driver
	where Schedule = 'Monday';
go

--select * from DriverMonday;

go


--2.Создать представление на основе полей обеих связанных таблиц задания 6.
if OBJECT_ID(N'office_and_route', N'V') is not null
	drop view office_and_route;
go
create view office_and_route as
	select 
		office.Address as name, 
		rout.RouteName as route
	from ControllersOffice office 
	inner join Route rout
		on office.RouteNumber = rout.RouteNumber;
go

--select * from office_and_route;
go


--3.Создать индекс для одной из таблиц задания 6, включив в него дополнительные неключевые поля.
if EXISTS (select name from sys.indexes 
			where name = N'Venicle_Year')
	drop index Venicle_Year on Venicle;
go
create index Venicle_Year
	on Venicle (NumberPlate)
	include (ManufactureYear);
go
SELECT * FROM Venicle WITH(INDEX(Venicle_Year)) WHERE (ManufactureYear >2000 )

--4.Создать индексированное представление.

if OBJECT_ID(N'Venicle_view', N'V') is not null
	drop view Venicle_view;
go

create view Venicle_view 
	with SCHEMABINDING	
	as select NumberPlate, ManufactureYear
	from dbo.Venicle
	where ManufactureYear > 2000;
go

if EXISTS (select name from sys.indexes 
			where name = N'Venicle_view')
	drop index Venicle_view on Venicle;
go
create UNIQUE CLUSTERED index Ind	on Venicle_view(NumberPlate, ManufactureYear);
go
--SELECT *  FROM Venicle_view
go