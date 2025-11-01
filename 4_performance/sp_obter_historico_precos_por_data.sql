USE CryptoDB;
GO

-- =================================================================
-- PROCEDURE: Consulta de Histórico de Preços
-- TIPO: Aplicação (pertence ao CryptoDB)
-- USO: Dashboards, relatórios, APIs
-- =================================================================

CREATE OR ALTER PROCEDURE dbo.sp_obter_historico_precos_por_data
    @CoinSymbol NVARCHAR(10),    -- Ex: 'BTC', 'ETH'
    @StartDate DATETIME,         -- Data inicial
    @EndDate DATETIME            -- Data final
AS
BEGIN
    SET NOCOUNT ON;

    -- Query sem otimização (SEM ÍNDICE)
    SELECT
        c.name AS Nome_Moeda,
        c.symbol AS Simbolo,
        ph.price_date AS Data_Preco,
        ph.price_usd AS Valor,
        ph.market_cap_usd AS Capitalizacao,
        ph.volume_usd AS Volume
    FROM dbo.price_history AS ph
    INNER JOIN dbo.coins AS c ON ph.coin_id = c.id
    WHERE c.symbol = @CoinSymbol
      AND ph.price_date BETWEEN @StartDate AND @EndDate
    ORDER BY ph.price_date;
END
GO

PRINT 'Procedure sp_obter_historico_precos_por_data criada';