-- 1. CRIANDO BANCO DE DADOS --
-- =============================================
USE master
GO

PRINT 'Criando Banco de Dados CryptoDB'

CREATE DATABASE CryptoDB

PRINT 'Banco CryptoDB criado !'

-- 2. CRIANDO TABELAS --
-- =============================================

USE CryptoDB;
GO

PRINT 'Criando tabelo coins'

CREATE TABLE coins (
    id NVARCHAR(50) PRIMARY KEY,
    symbol NVARCHAR(50) NOT NULL,
    name NVARCHAR(100) NOT NULL
);
GO

-- Tabela para guardar os registros de preço ao longo do tempo
-- Table to store price records over time

PRINT 'Criando tabelo price_history'

CREATE TABLE price_history (
    id INT PRIMARY KEY IDENTITY(1,1),
    coin_id NVARCHAR(50) NOT NULL,
    price_date DATETIME NOT NULL,
    price_usd FLOAT NOT NULL,
    market_cap_usd FLOAT NOT NULL,
    volume_usd FLOAT NOT NULL,
    FOREIGN KEY (coin_id) REFERENCES coins(id)
);
GO

PRINT 'Tabelas coins e price_history criadas com sucesso !'

-- 3. ALIMENTANDO TABELAS --
-- =============================================

USE CryptoDB;
GO

INSERT INTO [CryptoDB].[dbo].[coins] ([id], [symbol], [name])
VALUES 
('aave', 'aave', 'Aave'),
('algorand', 'algo', 'Algorand'),
('avalanche-2', 'avax', 'Avalanche'),
('bitcoin', 'btc', 'Bitcoin'),
('cardano', 'ada', 'Cardano'),
('chainlink', 'link', 'Chainlink'),
('cosmos', 'atom', 'Cosmos'),
('decentraland', 'mana', 'Decentraland'),
('dogecoin', 'doge', 'Dogecoin'),
('ethereum', 'eth', 'Ethereum'),
('fantom', 'ftm', 'Fantom'),
('hedera-hashgraph', 'hbar', 'Hedera'),
('litecoin', 'ltc', 'Litecoin'),
('maker', 'mkr', 'Maker'),
('monero', 'xmr', 'Monero'),
('polkadot', 'dot', 'Polkadot'),
('polygon', 'matic', 'Polygon'),
('ripple', 'xrp', 'XRP'),
('shiba-inu', 'shib', 'Shiba Inu'),
('solana', 'sol', 'Solana'),
('stellar', 'xlm', 'Stellar'),
('tezos', 'xtz', 'Tezos'),
('the-sandbox', 'sand', 'The Sandbox'),
('tron', 'trx', 'TRON'),
('uniswap', 'uni', 'Uniswap');

-- =================================================================
-- SCRIPT: Carga de Dados em Massa (2 Milhões de Registros)
-- DURAÇÃO ESPERADA: 2-5 minutos (versão otimizada)
-- =================================================================

SET NOCOUNT ON;
PRINT 'Iniciando carga de dados otimizada...';

-- Limpar dados antigos
TRUNCATE TABLE dbo.price_history;

-- 1️⃣ Tabela temporária com dados base das moedas
DECLARE @CoinPriceRanges TABLE (
    id NVARCHAR(50) PRIMARY KEY,
    symbol NVARCHAR(10),
    base_price DECIMAL(18, 4),
    base_market_cap BIGINT
);

-- Carregar moedas reais do cadastro
INSERT INTO @CoinPriceRanges (id, symbol, base_price, base_market_cap)
SELECT
    id,
    symbol,
    1 + (ABS(CHECKSUM(NEWID())) % 65000), -- Preço inicial aleatório
    1000000000 + (ABS(CHECKSUM(NEWID())) % 1300000000000) -- Market cap
FROM dbo.coins;

DECLARE @CoinCount INT = @@ROWCOUNT;
PRINT CAST(@CoinCount AS VARCHAR) + ' moedas carregadas na memória';

-- 2️⃣ Tabela de números para evitar loop lento
-- Cria 2 milhões de números de uma vez
DECLARE @Numbers TABLE (n INT PRIMARY KEY);

;WITH L0 AS (SELECT 1 AS c UNION ALL SELECT 1),     -- 2 linhas
     L1 AS (SELECT 1 AS c FROM L0 AS A, L0 AS B),   -- 4 linhas
     L2 AS (SELECT 1 AS c FROM L1 AS A, L1 AS B),   -- 16 linhas
     L3 AS (SELECT 1 AS c FROM L2 AS A, L2 AS B),   -- 256 linhas
     L4 AS (SELECT 1 AS c FROM L3 AS A, L3 AS B),   -- 65,536 linhas
     L5 AS (SELECT 1 AS c FROM L4 AS A, L4 AS B)    -- 4+ milhões linhas
INSERT INTO @Numbers (n)
SELECT TOP 2000000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
FROM L5;

PRINT 'Tabela de números criada (2M registros)';

-- 3️⃣ INSERT em lote (muito mais rápido que loop!)
DECLARE @StartDate DATETIME = DATEADD(YEAR, -2, GETDATE());
DECLARE @BatchSize INT = 100000;
DECLARE @CurrentBatch INT = 0;
DECLARE @TotalBatches INT = 2000000 / @BatchSize;

WHILE @CurrentBatch < @TotalBatches
BEGIN
    INSERT INTO dbo.price_history (coin_id, price_date, price_usd, market_cap_usd, volume_usd)
    SELECT
        cpr.id,
        DATEADD(MINUTE, 30 * (n.n + (@CurrentBatch * @BatchSize)), @StartDate) AS price_date,
        cpr.base_price * (0.85 + (ABS(CHECKSUM(NEWID())) % 100) / 100.0 * 0.30) AS price_usd,
        cpr.base_market_cap * (0.85 + (ABS(CHECKSUM(NEWID())) % 100) / 100.0 * 0.30) AS market_cap_usd,
        (cpr.base_market_cap / 100) * ((ABS(CHECKSUM(NEWID())) % 100) / 100.0 * 5) AS volume_usd
    FROM @Numbers n
    CROSS APPLY (
        SELECT TOP 1 * FROM @CoinPriceRanges ORDER BY NEWID()
    ) cpr
    WHERE n.n BETWEEN (@CurrentBatch * @BatchSize) + 1 AND (@CurrentBatch + 1) * @BatchSize;

    SET @CurrentBatch = @CurrentBatch + 1;
    PRINT 'Batch ' + CAST(@CurrentBatch AS VARCHAR) + '/' + CAST(@TotalBatches AS VARCHAR) + ' inserido...';
END

SET NOCOUNT OFF;

-- 4️⃣ Validação
DECLARE @TotalRows INT;
SELECT @TotalRows = COUNT(*) FROM dbo.price_history;
PRINT '';
PRINT 'Carga concluída com sucesso!';
PRINT 'Total de registros: ' + CAST(@TotalRows AS VARCHAR);
PRINT 'Período: ' + CAST(@StartDate AS VARCHAR) + ' até ' + CAST(GETDATE() AS VARCHAR);
GO