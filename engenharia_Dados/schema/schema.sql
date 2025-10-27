-- Checa se a tabela coins já existe e, se sim, a deleta para recomeçar.
-- Check if the coins table already exists and, if so, delete it to start over. 
IF OBJECT_ID('coins', 'U') IS NOT NULL
    DROP TABLE coins;
GO

-- Checa se a tabela price_history já existe e, se sim, a deleta.
-- Checks if the price_history table already exists and, if so, deletes it.
IF OBJECT_ID('price_history', 'U') IS NOT NULL
    DROP TABLE price_history;
GO

-- Tabela para guardar as informações de cada moeda
-- Table to store information about each currency
CREATE TABLE coins (
    id NVARCHAR(50) PRIMARY KEY,
    symbol NVARCHAR(50) NOT NULL,
    name NVARCHAR(100) NOT NULL
);
GO

-- Tabela para guardar os registros de preço ao longo do tempo
-- Table to store price records over time
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
