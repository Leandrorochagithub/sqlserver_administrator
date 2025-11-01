USE CryptoDB;
GO

-- Habilitar m�tricas de performance
SET STATISTICS TIME ON;   -- Medir tempo de CPU e elapsed time
SET STATISTICS IO ON;     -- Medir leituras de disco/mem�ria

PRINT '============================================';
PRINT 'TESTE DE PERFORMANCE: ANTES DA OTIMIZA��O';
PRINT '============================================';
PRINT '';

-- Limpar cache para teste justo
DBCC DROPCLEANBUFFERS;  -- Remove dados da mem�ria
DBCC FREEPROCCACHE;     -- Remove planos de execu��o compilados

-- Executar query problema
EXEC dbo.sp_obter_historico_precos_por_data
    @CoinSymbol = 'BTC',
    @StartDate = '2036-08-26',
    @EndDate = '2036-09-26';

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO