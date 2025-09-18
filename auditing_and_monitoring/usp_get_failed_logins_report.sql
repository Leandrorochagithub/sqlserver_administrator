USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'DBA_Admin')
BEGIN
    CREATE DATABASE [DBA_Admin];
    PRINT 'Banco de dados [DBA_Admin] criado para ferramentas de administração.';
END
GO


USE [DBA_Admin];
GO


CREATE OR ALTER PROCEDURE dbo.usp_GetFailedLoginsReport
    @Days INT = 7
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ErrorLogCount INT;
    DECLARE @LastLogDate DATETIME;
    DECLARE @StartDate DATETIME = DATEADD(DAY, -@Days, GETDATE());

    DECLARE @ErrorLogInfo TABLE
    (
        LogDate DATETIME,
        ProcessInfo NVARCHAR(50),
        [Text] NVARCHAR(MAX)
    );

    DECLARE @EnumErrorLogs TABLE
    (
        [Archive#] INT,
        [Date] DATETIME,
        LogFileSizeMB INT
    );

    INSERT INTO @EnumErrorLogs
    EXEC sp_enumerrorlogs;

    SELECT @ErrorLogCount = MIN([Archive#])
    FROM @EnumErrorLogs;

    WHILE @ErrorLogCount IS NOT NULL
    BEGIN
        INSERT INTO @ErrorLogInfo
        EXEC sp_readerrorlog @ErrorLogCount, 1, 'Login', 'failed';

        SELECT @ErrorLogCount = MIN([Archive#])
        FROM @EnumErrorLogs
        WHERE [Archive#] > @ErrorLogCount
          AND [Date] >= @StartDate;
    END;

    WITH FailedLogins AS (
        SELECT 
            LogDate,
            [Text],
            SUBSTRING(
                [Text], 
                CHARINDEX('''', [Text]) + 1, 
                CHARINDEX('''', [Text], CHARINDEX('''', [Text]) + 1) - CHARINDEX('''', [Text]) - 1
            ) AS LoginName,
            CASE 
                WHEN CHARINDEX('[CLIENT: ', [Text]) > 0 THEN
                    SUBSTRING(
                        [Text], 
                        CHARINDEX('[CLIENT: ', [Text]) + 8, 
                        CHARINDEX(']', [Text], CHARINDEX('[CLIENT: ', [Text])) - CHARINDEX('[CLIENT: ', [Text]) - 8
                    )
                ELSE 'N/A'
            END AS ClientIP
        FROM @ErrorLogInfo
        WHERE LogDate >= @StartDate
    )
    SELECT 
        COUNT(*) AS NumberOfAttempts,
        LoginName,
        ClientIP,
        MIN(LogDate) AS FirstAttempt,
        MAX(LogDate) AS LastAttempt,
        MIN([Text]) AS SampleErrorDetails 
    FROM FailedLogins
    GROUP BY LoginName, ClientIP
    ORDER BY NumberOfAttempts DESC;

END
GO

PRINT 'Procedure [usp_GetFailedLoginsReport] criada/atualizada com sucesso no banco de dados [DBA_Admin].';
GO