USE CryptoDB;
GO

PRINT 'Iniciando a inser��o de dados em massa (vers�o FINAL e correta).';
SET NOCOUNT ON;

-- Limpa a tabela para um novo come�o.
TRUNCATE TABLE dbo.price_history;

-- 1. Criar uma tabela na mem�ria
DECLARE @CoinPriceRanges TABLE (
    id NVARCHAR(50) PRIMARY KEY,
    base_price DECIMAL(18, 4),
    base_market_cap BIGINT
);

-- 2. Carrega os dados REAIS da tabela dbo.coins
INSERT INTO @CoinPriceRanges (id, base_price, base_market_cap)
SELECT
    id,
    1 + (ABS(CHECKSUM(NEWID())) % 65000), -- Pre�o base aleat�rio
    1000000000 + (ABS(CHECKSUM(NEWID())) % 1300000000000) -- Market Cap aleat�rio
FROM
    dbo.coins;

PRINT CONVERT(VARCHAR, @@ROWCOUNT) + ' moedas reais carregadas na mem�ria. Iniciando o loop de inser��o...';

-- 3. Loop principal para inserir dados
DECLARE @Counter INT = 0;
DECLARE @TotalRows INT = 2000000;
DECLARE @CurrentDate DATETIME = DATEADD(YEAR, -2, GETDATE()); -- Come�a h� dois anos

DECLARE @RandomCoinID NVARCHAR(50);
DECLARE @BasePrice DECIMAL(18, 4);
DECLARE @BaseMarketCap BIGINT;

BEGIN TRY
    WHILE @Counter < @TotalRows
    BEGIN
        -- Sorteia uma moeda aleat�ria da tabela tempor�ria
        SELECT TOP 1 @RandomCoinID = id, @BasePrice = base_price, @BaseMarketCap = base_market_cap
        FROM @CoinPriceRanges ORDER BY NEWID();

        -- Insere o registro
        INSERT INTO dbo.price_history (coin_id, price_date, price_usd, market_cap_usd, volume_usd)
        VALUES (
            @RandomCoinID,
            @CurrentDate,
            @BasePrice * (0.85 + RAND() * 0.30),
            @BaseMarketCap * (0.85 + RAND() * 0.30),
            (@BaseMarketCap / 100) * (RAND() * 5)
        );

        -- Avan�a o tempo e o contador
        SET @CurrentDate = DATEADD(MINUTE, 30, @CurrentDate);
        SET @Counter = @Counter + 1;

        -- Feedback de progresso
        IF @Counter % 100000 = 0
        BEGIN
            PRINT CONVERT(VARCHAR, @Counter) + ' de ' + CONVERT(VARCHAR, @TotalRows) + ' linhas inseridas...';
        END
    END
END TRY
BEGIN CATCH
    PRINT 'Ocorreu um erro durante a inser��o!';
    PRINT 'Erro: ' + ERROR_MESSAGE();
END CATCH

SET NOCOUNT OFF;
PRINT 'Carga de dados massivos conclu�da!';
GO

-- Verifica a contagem final de linhas
SELECT COUNT(*) AS TotalRowsInPriceHistory FROM dbo.price_history;
GO