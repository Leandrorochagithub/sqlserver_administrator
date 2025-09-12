-- =============================================
-- Autor:        Leandro Ferreira
-- Data de Cria��o: 2025-09-01
-- Descri��o:    Cria um login e usu�rio para o projeto de Criptomoedas,
--               concedendo permiss�es m�nimas e espec�ficas
--               para as tarefas de ETL.
-- ATUALIZA��O:  Adicionada permiss�o de INSERT e UPDATE na tabela de moedas.
-- =============================================

USE master;
GO

-- 1. Cria o Login para a aplica��o de ETL do projeto Crypto
--    � uma boa pr�tica ter logins separados para projetos diferentes.
-- SELECT 1: � uma consulta b�sica, n�o precisamos gerar um estresse de consulta no banco usando *, por exemplo
IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = 'app_etl_crypto')
BEGIN
    CREATE LOGIN app_etl_crypto WITH PASSWORD = 'P@ssword';
END
GO


USE CryptoDB;
GO

-- 2. Cria o Usu�rio no banco de dados, associado ao Login
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'app_etl_crypto')
BEGIN
    CREATE USER app_etl_crypto FOR LOGIN app_etl_crypto;
END
GO

-- 3. Concede as permiss�es m�nimas e espec�ficas conforme sua an�lise
PRINT 'Concedendo permiss�es para o usu�rio app_etl_crypto...';

-- Permiss�o de LEITURA (SELECT), INSER��O (INSERT) e ATUALIZA��O (UPDATE) na tabela de moedas e na tabela de pre�o.
-- A aplica��o agora pode adicionar novas moedas � lista.
GRANT SELECT, INSERT, UPDATE ON dbo.coins TO app_etl_crypto;
PRINT '- Permiss�es SELECT, INSERT, UPDATE concedidas em dbo.coins.';


GRANT SELECT, INSERT, UPDATE ON dbo.price_history TO app_etl_crypto;
PRINT '- Permiss�es SELECT, UPDATE concedidas em dbo.price_history.';

-- Negando explicitamente permiss�es perigosas (opcional, mas boa pr�tica)
DENY DELETE ON dbo.price_history TO app_etl_crypto;
DENY DELETE ON dbo.coins TO app_etl_crypto;
GO

PRINT 'Modelo de seguran�a para o projeto Crypto atualizado com sucesso.';

-- 03/09/2025

USE master
GO

PRINT 'Criando login...'
IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE NAME = 'usr_crypto_ro')
BEGIN
	CREATE LOGIN usr_crypto_ro WITH PASSWORD = 'P@ssw0rd'
END
GO
PRINT 'Login criado !'


IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE NAME = 'usr_crypto_ro')
BEGIN
	CREATE USER usr_crypto_ro FOR LOGIN usr_crypto_ro 
END
GO
PRINT 'Usuario usr_crypto_ro atribuido ao login usr_crypto_ro !'

USE CryptoDB
GO


PRINT 'Concedendo permissoes de LEITURA para o usuario usr_crypto_ro...';
GRANT SELECT ON dbo.coins TO usr_crypto_ro;
PRINT '- Permissao SELECT concedida em dbo.coins.';


GRANT SELECT ON dbo.price_history TO usr_crypto_ro;
PRINT '- Permissao SELECT concedida em dbo.price_history.';