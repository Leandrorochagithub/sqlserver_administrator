-- =============================================
-- Autor:        Leandro Ferreira
-- Data de Criação: 2025-09-01
-- Descrição:    Cria um login e usuário para o projeto de Criptomoedas,
--               concedendo permissões mínimas e específicas
--               para as tarefas de ETL.
-- ATUALIZAÇÃO:  Adicionada permissão de INSERT e UPDATE na tabela de moedas.
-- =============================================

USE master;
GO

-- 1. Cria o Login para a aplicação de ETL do projeto Crypto
--    É uma boa prática ter logins separados para projetos diferentes.
-- SELECT 1: É uma consulta básica, não precisamos gerar um estresse de consulta no banco usando *, por exemplo
IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = 'app_etl_crypto')
BEGIN
    CREATE LOGIN app_etl_crypto WITH PASSWORD = 'P@ssword';
END
GO


USE CryptoDB;
GO

-- 2. Cria o Usuário no banco de dados, associado ao Login
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'app_etl_crypto')
BEGIN
    CREATE USER app_etl_crypto FOR LOGIN app_etl_crypto;
END
GO

-- 3. Concede as permissões mínimas e específicas conforme sua análise
PRINT 'Concedendo permissões para o usuário app_etl_crypto...';

-- Permissão de LEITURA (SELECT), INSERÇÃO (INSERT) e ATUALIZAÇÃO (UPDATE) na tabela de moedas e na tabela de preço.
-- A aplicação agora pode adicionar novas moedas à lista.
GRANT SELECT, INSERT, UPDATE ON dbo.coins TO app_etl_crypto;
PRINT '- Permissões SELECT, INSERT, UPDATE concedidas em dbo.coins.';


GRANT SELECT, INSERT, UPDATE ON dbo.price_history TO app_etl_crypto;
PRINT '- Permissões SELECT, UPDATE concedidas em dbo.price_history.';

-- Negando explicitamente permissões perigosas (opcional, mas boa prática)
DENY DELETE ON dbo.price_history TO app_etl_crypto;
DENY DELETE ON dbo.coins TO app_etl_crypto;
GO

PRINT 'Modelo de segurança para o projeto Crypto atualizado com sucesso.';