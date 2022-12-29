USE LAB6
GO

--Создать хранимую процедуру, производящую выборку
--из некоторой таблицы и возвращающую результат
--выборки в виде курсора.
DECLARE @temp_cursor CURSOR
DROP PROCEDURE IF EXISTS selection1
GO
CREATE PROCEDURE dbo.selection1 @currently_cursor CURSOR VARYING OUTPUT AS
    SET @currently_cursor = CURSOR
    FORWARD_ONLY STATIC FOR
    SELECT MiddleName,PhoneNumber FROM Driver
    OPEN @currently_cursor
GO
EXECUTE dbo.selection1 @currently_cursor = @temp_cursor OUTPUT
FETCH NEXT FROM @temp_cursor
WHILE (@@FETCH_STATUS = 0)
BEGIN
	FETCH NEXT FROM @temp_cursor
END
CLOSE @temp_cursor
DEALLOCATE @temp_cursor
GO
--Модифицировать хранимую процедуру п.1. таким
--образом, чтобы выборка осуществлялась с
--формированием столбца, значение которого
--формируется пользовательской функцией.

DROP FUNCTION IF EXISTS getYear

GO

CREATE FUNCTION getYear(@a Date,@b Date)
	RETURNS INT
	AS
		BEGIN
            DECLARE @number INT
            SET @number=YEAR(@b)-YEAR(@a)
            RETURN @number
		END
GO
DROP PROCEDURE IF EXISTS dbo.selection2 
GO
CREATE PROCEDURE dbo.selection2 @cur_cursor CURSOR VARYING OUTPUT AS
    SET @cur_cursor = CURSOR FORWARD_ONLY STATIC FOR
    SELECT MiddleName,PhoneNumber,dbo.getYear(DateOfBirth,GETDATE()) as Year_from_birth FROM Driver
    OPEN @cur_cursor
GO
DECLARE @temp_cursor1 CURSOR
EXECUTE dbo.selection2 @cur_cursor=@temp_cursor1 OUTPUT
FETCH NEXT FROM @temp_cursor1
WHILE (@@FETCH_STATUS = 0)
	BEGIN
		FETCH NEXT FROM @temp_cursor1
	END

CLOSE @temp_cursor1
DEALLOCATE @temp_cursor1
GO
--Создать хранимую процедуру, вызывающую процедуру
--п.1., осуществляющую прокрутку возвращаемого
--курсора и выводящую сообщения, сформированные из
--записей при выполнении условия, заданного еще одной
--пользовательской функцией.

DROP FUNCTION IF EXISTS PhoneCheck

GO
CREATE FUNCTION PhoneCheck(@a NVARCHAR(60))
    RETURNS VARCHAR
    AS
        BEGIN
            DECLARE @verdict INT
            IF LEN(@a)>11 SET @verdict=0 ELSE SET @verdict=1
            RETURN (@verdict)
        END

GO
DROP PROCEDURE IF EXISTS dbo.updatedProcedure
GO

CREATE PROCEDURE dbo.updatedProcedure AS
    DECLARE @j CURSOR
    DECLARE @MiddleName NVARCHAR(60)
    DECLARE @PhoneNumber NVARCHAR(60)

    EXECUTE dbo.selection1 @currently_cursor = @j OUTPUT

    FETCH NEXT FROM @j INTO @MiddleName,@PhoneNumber

    WHILE (@@FETCH_STATUS=0)
    BEGIN
        IF (dbo.PhoneCheck(@PhoneNumber)>0)
            PRINT @MiddleName + '  Phone ok '
        ELSE
            print @MiddleName + '  bad Phone '
        FETCH NEXT FROM @j INTO @MiddleName,@PhoneNumber
    END

    CLOSE @j
    DEALLOCATE @j
GO

EXECUTE dbo.updatedProcedure

GO
--Модифицировать хранимую процедуру п.2. таким
--образом, чтобы выборка формировалась с помощью
--табличной функции.
DROP FUNCTION IF EXISTS dbo.tableFunction
GO
CREATE FUNCTION tableFunction() 
RETURNS @resultTable TABLE (
    Name NVARCHAR(60) NOT NULL,
    Phone NVARCHAR(60) NOT NULL,
    Age INT NOT NULL
)
AS
    BEGIN
        INSERT @resultTable 
        SELECT MiddleName,PhoneNumber,dbo.getYear(DateOfBirth,GETDATE()) as Year_from_birth FROM Driver
        WHERE dbo.PhoneCheck(PhoneNumber)>0
        RETURN 
    END
GO

ALTER PROCEDURE dbo.selection2 @cursor CURSOR VARYING OUTPUT
AS
    SET @cursor = CURSOR 
	FORWARD_ONLY STATIC FOR 
	SELECT * FROM dbo.tableFunction()
	OPEN @cursor
GO

DECLARE @table_cursor CURSOR
EXECUTE dbo.selection2 @cursor = @table_cursor OUTPUT

DECLARE @name NVARCHAR(60)
DECLARE @phone NVARCHAR(60)
DECLARE @age INT

FETCH NEXT FROM @table_cursor INTO @name,@phone,@age

WHILE (@@FETCH_STATUS = 0)
	BEGIN
		FETCH NEXT FROM @table_cursor INTO @name,@phone,@age
        PRINT @name+ ' '+@phone +' '+CAST(@age as NVARCHAR(20))
	END
CLOSE @table_cursor
DEALLOCATE @table_cursor
