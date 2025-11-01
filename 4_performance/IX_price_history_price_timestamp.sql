USE CryptoDB;
GO

-- ============================================
-- CRIAR �NDICE OTIMIZADO
-- ============================================

PRINT 'Criando �ndice otimizado...';
PRINT '';

-- Verificar se j� existe (precau��o)
IF EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE object_id = OBJECT_ID('dbo.price_history') 
      AND name = 'IX_price_history_coin_date'
)
BEGIN
    PRINT '�ndice j� existe! Recriando...';
    DROP INDEX IX_price_history_coin_date ON dbo.price_history;
END

-- Criar �ndice COVERING (otimizado)
CREATE NONCLUSTERED INDEX IX_price_history_coin_date
ON dbo.price_history (coin_id, price_date)
INCLUDE (price_usd, market_cap_usd, volume_usd)
WITH (
    FILLFACTOR = 90,           -- 10% espa�o livre para INSERTs
    SORT_IN_TEMPDB = ON,       -- Construir em tempdb (mais r�pido)
    STATISTICS_NORECOMPUTE = OFF,
    ONLINE = OFF               -- Tabela fica bloqueada durante cria��o
);

PRINT '�ndice IX_price_history_coin_date criado!';
PRINT '';
PRINT 'Detalhes do �ndice:';
PRINT '  Tipo: NONCLUSTERED COVERING INDEX';
PRINT '  Chaves: coin_id, price_date';
PRINT '  INCLUDE: price_usd, market_cap_usd, volume_usd';
PRINT '  FillFactor: 90%';
PRINT '';

-- Atualizar estat�sticas
UPDATE STATISTICS dbo.price_history IX_price_history_coin_date WITH FULLSCAN;
PRINT 'Estat�sticas atualizadas!';
GO