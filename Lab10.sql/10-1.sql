

use lab10;
go 

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--SET TRANSACTION ISOLATION LEVEL READ COMMITTED
--SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE


-- dirty read
-- BEGIN TRANSACTION
--     SELECT FirstName, PhoneNumber FROM [Controller]
--     SELECT request_session_id, request_type, request_mode, resource_database_id FROM sys.dm_tran_locks
-- COMMIT TRANSACTION
-- go

-- -- nonrepeatable read
-- BEGIN TRANSACTION
--     SELECT FirstName, PhoneNumber FROM [Controller]
--     WAITFOR DELAY '00:00:10'
--     SELECT FirstName, PhoneNumber FROM [Controller]
--     SELECT request_session_id, request_type, request_mode, resource_database_id FROM sys.dm_tran_locks
-- COMMIT TRANSACTION
-- go

-- -- phantom read
BEGIN TRANSACTION
    SELECT FirstName, PhoneNumber FROM [Controller]
    WAITFOR DELAY '00:00:10'
    SELECT FirstName, PhoneNumber FROM [Controller]
    SELECT request_session_id, request_type, request_mode, resource_database_id FROM sys.dm_tran_locks
COMMIT TRANSACTION
go