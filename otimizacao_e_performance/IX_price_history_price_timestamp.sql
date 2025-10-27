USE CryptoDB;
GO

PRINT 'Criando �ndice otimizado na coluna de data...';

CREATE NONCLUSTERED INDEX IX_price_history_price_timestamp
ON dbo.price_history (price_timestamp)
INCLUDE (price_usd, coin_id); -- INCLUDE otimiza ainda mais, criando um "covering index"

PRINT '�ndice IX_price_history_price_timestamp criado com sucesso!';
GO