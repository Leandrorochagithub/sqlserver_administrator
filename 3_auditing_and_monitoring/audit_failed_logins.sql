-- ================================================
-- Script: Coletar tentativas de login com falha
-- no SQL Server nos últimos 7 dias
-- ================================================

-- Variáveis de controle
DECLARE @ErrorLogCount INT;      -- Número do arquivo de log a ser lido
DECLARE @LastLogDate DATETIME;   -- Data mais recente encontrada no log

-- Tabela para armazenar o conteúdo dos logs de erro lidos
DECLARE @ErrorLogInfo TABLE
(
    LogDate DATETIME,           -- Data e hora do evento
    ProcessInfo NVARCHAR(50),   -- Tipo do processo (ex: Logon, Backup, etc.)
    [Text] NVARCHAR(MAX)        -- Mensagem completa do log
);

-- Tabela para armazenar a lista de arquivos de log existentes
DECLARE @EnumErrorLogs TABLE
(
    [Archive#] INT,             -- Número do arquivo de log (0 = atual)
    [Date] DATETIME,             -- Data da criação/modificação do log
    LogFileSizeMB INT            -- Tamanho do arquivo em MB
);

-- Passo 1: Obter a lista de todos os arquivos de log disponíveis
INSERT INTO @EnumErrorLogs
EXEC sp_enumerrorlogs;

-- Passo 2: Começar pelo arquivo mais antigo
SELECT @ErrorLogCount = MIN([Archive#]),
       @LastLogDate = MAX([Date])
FROM @EnumErrorLogs;

-- Passo 3: Loop para percorrer cada log até o mais recente
WHILE @ErrorLogCount IS NOT NULL
BEGIN
    -- Inserir no @ErrorLogInfo apenas registros que contenham "Login" e "failed"
    -- Isso já filtra no momento da leitura para evitar excesso de dados
    INSERT INTO @ErrorLogInfo
    EXEC sp_readerrorlog @ErrorLogCount, 1, 'Login', 'failed';

    -- Avança para o próximo arquivo de log que esteja dentro dos últimos 7 dias
    SELECT @ErrorLogCount = MIN([Archive#]),
           @LastLogDate = MAX([Date])
    FROM @EnumErrorLogs
    WHERE [Archive#] > @ErrorLogCount
      AND [Date] >= DATEADD(DAY, -7, GETDATE());
END;

-- Passo 4: Consulta para extrair o usuário e o IP
-- Esta consulta transforma a coluna [Text] em informações mais detalhadas
WITH FailedLogins AS (
    SELECT 
        LogDate,
        [Text],
        -- Extrai o nome do usuário da mensagem de erro
        SUBSTRING(
            [Text], 
            CHARINDEX('''', [Text]) + 1, 
            CHARINDEX('''', [Text], CHARINDEX('''', [Text]) + 1) - CHARINDEX('''', [Text]) - 1
        ) AS LoginName,
        -- Extrai o endereço de IP do cliente, se disponível
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
    WHERE LogDate >= DATEADD(DAY, -7, GETDATE())
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