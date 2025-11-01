USE CryptoDB;
GO

-- ============================================
-- CRIAR ÍNDICE OTIMIZADO
-- ============================================

PRINT 'Criando índice otimizado...';
PRINT '';

-- Verificar se já existe (precaução)
IF EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE object_id = OBJECT_ID('dbo.price_history') 
      AND name = 'IX_price_history_coin_date'
)
BEGIN
    PRINT 'Índice já existe! Recriando...';
    DROP INDEX IX_price_history_coin_date ON dbo.price_history;
END

-- Criar índice COVERING (otimizado)
CREATE NONCLUSTERED INDEX IX_price_history_coin_date
ON dbo.price_history (coin_id, price_date)
INCLUDE (price_usd, market_cap_usd, volume_usd)
WITH (
    FILLFACTOR = 90,           -- 10% espaço livre para INSERTs
    SORT_IN_TEMPDB = ON,       -- Construir em tempdb (mais rápido)
    STATISTICS_NORECOMPUTE = OFF,
    ONLINE = OFF               -- Tabela fica bloqueada durante criação
);

PRINT 'Índice IX_price_history_coin_date criado!';
PRINT '';
PRINT 'Detalhes do índice:';
PRINT '  Tipo: NONCLUSTERED COVERING INDEX';
PRINT '  Chaves: coin_id, price_date';
PRINT '  INCLUDE: price_usd, market_cap_usd, volume_usd';
PRINT '  FillFactor: 90%';
PRINT '';

-- Atualizar estatísticas
UPDATE STATISTICS dbo.price_history IX_price_history_coin_date WITH FULLSCAN;
PRINT 'Estatísticas atualizadas!';
GO