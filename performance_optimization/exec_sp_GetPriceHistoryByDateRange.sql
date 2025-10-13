USE CryptoDB;
GO

-- Habilita estatísticas para medir a performance
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

PRINT 'Executando a procedure LENTA...';

-- Executa a procedure para buscar 1 mês de dados do Bitcoin
EXEC dbo.sp_GetPriceHistoryByDateRange
    @CoinSymbol = 'btc',
    @StartDate = '2025-06-01',
    @EndDate = '2025-06-30';

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO