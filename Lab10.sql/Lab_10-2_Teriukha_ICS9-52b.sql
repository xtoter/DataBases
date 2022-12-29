use lab10;
go 

-- dirty read
-- BEGIN TRANSACTION
-- go
--     SELECT FirstName, PhoneNumber FROM Or[Controller]ders
--     UPDATE [Controller] SET PhoneNumber = '900' WHERE FirstName = 'Alexey'
--     SELECT FirstName, PhoneNumber FROM [Controller]
--     WAITFOR DELAY '00:00:10'
--     ROLLBACK
--     SELECT FirstName, PhoneNumber FROM [Controller]
--     SELECT request_session_id, request_type, request_mode, resource_database_id FROM sys.dm_tran_locks
-- go

-- -- nonrepeatable read
-- BEGIN TRANSACTION
--     SELECT FirstName, PhoneNumber FROM [Controller]
--     UPDATE [Controller] SET PhoneNumber = '900' WHERE FirstName = 'Alexey'
--     SELECT FirstName, PhoneNumber FROM [Controller]
--     SELECT request_session_id, request_type, request_mode, resource_database_id FROM sys.dm_tran_locks
--     COMMIT TRANSACTIONOrders
-- go


-- -- phantom read
BEGIN TRANSACTION
    SELECT FirstName, PhoneNumber FROM [Controller]
    INSERT INTO [Controller]  (FirstName,MiddleName,SecondName, PhoneNumber,Schedule,DateOfBirth) VALUES  
    (N'Matvey',' Zaharov','Olegovich','79806664728','Monday', '1999-12-06')

    SELECT FirstName, PhoneNumber FROM [Controller]
    SELECT resource_type, resource_description, request_mode FROM sys.dm_tran_locks
    COMMIT TRANSACTION
go