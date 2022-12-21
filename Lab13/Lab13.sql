--1.Создать две базы данных на одном экземпляре СУБД SQL Server 2012.
use master;
go
if DB_ID (N'lab13a') is not null
	drop database lab13a;
go
create database lab13a
go


use master;
go
if DB_ID (N'lab13b') is not null
	drop database lab13b;
go
create database lab13b
go



--2.Создать в базах данных п.1. горизонтально фрагментированные таблицы.
use lab13a;
go
if OBJECT_ID(N'dbo.Venicle', N'U') is not null
    drop table dbo.Venicle;
go
CREATE TABLE Venicle(
    VenicleID INT    PRIMARY KEY ,
    NumberPlate NVARCHAR(10) NOT NULL,
    Brand NVARCHAR(50),
    ManufactureYear INT NOT NULL,
    Capacity INT NOT NULL,
    MaximumSpeed INT,
	CONSTRAINT Check_id
                CHECK (VenicleID <= 5)
)
go


use lab13b;
go
if OBJECT_ID(N'dbo.Venicle', N'U') is not null
    drop table dbo.Venicle;
go
CREATE TABLE Venicle(
    VenicleID INT    PRIMARY KEY ,
    NumberPlate NVARCHAR(10) NOT NULL,
    Brand NVARCHAR(50),
    ManufactureYear INT NOT NULL,
    Capacity INT NOT NULL,
    MaximumSpeed INT,
	CONSTRAINT Check_id
                CHECK (VenicleID > 5)
)
go



--3.Создать секционированные представления, обеспечивающие работу с данными таблиц 
	--(выборку, вставку, изменение, удаление).
use lab13a;
go
if OBJECT_ID(N'horizontal_dist_v', N'V') is not null
	drop view horizontal_dist_v;
go
create view horizontal_dist_v as
	select * from lab13a.dbo.Venicle
	union all					
	select * from lab13b.dbo.Venicle
go


insert horizontal_dist_v values
	(1,'VO879Y','VAZ',1999,40,15),
	(3,'V1179Y','YAZ',1929,40,15),
	(10,'VO879Y','UNKOWN',1999,40,15);

select * from horizontal_dist_v

update horizontal_dist_v
	set Brand = '?'
	where Brand='YAZ'

delete horizontal_dist_v
	where Brand = 'UNKOWN'

select * from lab13a.dbo.Venicle;
select * from lab13b.dbo.Venicle;
