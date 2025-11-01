USE CryptoDB;
GO

-- Habilitar métricas de performance
SET STATISTICS TIME ON;   -- Medir tempo de CPU e elapsed time
SET STATISTICS IO ON;     -- Medir leituras de disco/memória

PRINT '============================================';
PRINT 'TESTE DE PERFORMANCE: ANTES DA OTIMIZAÇÃO';
PRINT '============================================';
PRINT '';

-- Limpar cache para teste justo
DBCC DROPCLEANBUFFERS;  -- Remove dados da memória
DBCC FREEPROCCACHE;     -- Remove planos de execução compilados

-- Executar query problema
EXEC dbo.sp_obter_historico_precos_por_data
    @CoinSymbol = 'BTC',
    @StartDate = '2036-08-26',
    @EndDate = '2036-09-26';

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO