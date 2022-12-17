USE LAB6
GO

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
			RAISERROR('[insert]: Bad Number', 10, 1);
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
			print '[DELETE]: Entries with "Price" >= ' + CAST(25 as varchar) + ' are deleted'
			delete from dbo.Route
				where Route.Price >= 25
		end
go
INSERT INTO Route(RouteNumber,RouteName, Price) VALUES
(0,'vokzal', 26), (4,'airport', 40)
delete from dbo.Route where RouteNumber > 25;
select * from dbo.Route;



--Для представления пункта 2 задания 7 создать
--триггеры на вставку, удаление и добавление,
--обеспечивающие возможность выполнения
--операций с данными непосредственно через
--представление.

--тут весело

--		office.Address as name, 
--		rout.RouteName as route,
--		rout.RouteNumber as num,

if OBJECT_ID(N'dbo.office_and_route_trigger_insert', N'TR') is not null
	drop trigger dbo.office_and_route_trigger_insert
go
create trigger dbo.office_and_route_trigger_insert
	on dbo.office_and_route
	instead of insert
	as
	begin
	--IF EXISTS(SELECT Address FROM ControllersOffice WHERE Address = name)
		INSERT INTO ControllersOffice(Address) SELECT name FROM inserted WHERE  (SELECT Address FROM ControllersOffice WHERE Address = name) is not null
		INSERT INTO Route(RouteNumber,RouteName) SELECT num,route FROM inserted WHERE NOT (SELECT route FROM inserted) IN (SELECT RouteName FROM Route)	
	end
go
INSERT INTO office_and_route(name,route,num) VALUES
('pyskina 4','bus station',39)
--del
if OBJECT_ID(N'dbo.office_and_route_trigger_delete', N'TR') is not null
	drop trigger dbo.office_and_route_trigger_delete
go
create trigger dbo.office_and_route_trigger_delete
	on dbo.office_and_route
	instead of delete
	as
	begin
		delete from dbo.Route
			where Route.RouteNumber  in (select d.num from deleted as d)
	
	end
go
--delete from dbo.office_and_route
--	where office_and_route.num = 3

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
			update dbo.Route
				set 
					Route.RouteName  = (select route from inserted where inserted.num = Route.RouteNumber)
	end
go
update dbo.office_and_route 
	set route = 'bus station2'
		
	where office_and_route.route = 'bus station';
