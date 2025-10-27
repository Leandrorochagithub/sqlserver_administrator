USE DBA_Admin; -- <<<<<< IMPORTANTE: Estamos no contexto do banco de administra��o
GO

CREATE OR ALTER PROCEDURE dbo.sp_Admin_CheckIndexFragmentation
    @TargetDatabase NVARCHAR(128) = 'CryptoDB', -- Par�metro para o nome do banco
    @TargetTable NVARCHAR(128) = 'price_history' -- Par�metro para o nome da tabela
AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Analisando a fragmenta��o para: ' + @TargetDatabase + '.' + @TargetTable;

    -- Usamos SQL Din�mico para poder consultar as tabelas do sistema
    -- do banco de dados alvo.
    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
        USE ' + QUOTENAME(@TargetDatabase) + N';

        SELECT
            OBJECT_NAME(ips.object_id) AS TableName,
            i.name AS IndexName,
            ips.index_type_desc,
            ips.avg_fragmentation_in_percent,
            ips.page_count
        FROM
            sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID(@TableName), NULL, NULL, ''SAMPLED'') AS ips
        INNER JOIN
            sys.indexes AS i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
        WHERE
            ips.avg_fragmentation_in_percent > 5
        ORDER BY
            ips.avg_fragmentation_in_percent DESC;
    ';

    -- Executa o SQL din�mico
    EXEC sp_executesql @SQL, N'@TableName NVARCHAR(128)', @TargetTable;

END
GO

PRINT 'Procedure de DBA sp_Admin_CheckIndexFragmentation criada com sucesso em DBA_Admin.';