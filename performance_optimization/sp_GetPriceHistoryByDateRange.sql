USE CryptoDB;
GO 


CREATE OR ALTER PROCEDURE dbo.sp_GetPriceHistoryByDateRange
    @CoinSymbol NVARCHAR(10),
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.name, 
        ph.price_date, 
        ph.price_usd
    FROM
        dbo.price_history AS ph
    INNER JOIN
        dbo.coins AS c ON ph.coin_id = c.id
    WHERE
        c.symbol = @CoinSymbol
        AND ph.price_date BETWEEN @StartDate AND @EndDate
    ORDER BY
        ph.price_date;
END
GO -- <== FIM DO LOTE 2. Boa prática para finalizar o script.

PRINT 'Stored Procedure sp_GetPriceHistoryByDateRange criada/alterada com sucesso.';