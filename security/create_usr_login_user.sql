-- =====================================================
-- USUÁRIO READ-ONLY: Consultas e Relatórios
-- Propósito: Acesso de leitura para análise de dados
-- Nível de Privilégio: Somente SELECT
-- =====================================================

IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = 'usr_crypto_ro')
BEGIN
    CREATE LOGIN usr_crypto_ro 
    WITH PASSWORD = N'$(RO_PASSWORD)',
         CHECK_POLICY = ON,
         CHECK_EXPIRATION = ON;
    
    PRINT '✓ Login [usr_crypto_ro] criado com sucesso.';
END
ELSE
BEGIN
    PRINT '⚠ Login [usr_crypto_ro] já existe.';
END
GO

USE CryptoDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_crypto_ro')
BEGIN
    CREATE USER usr_crypto_ro FOR LOGIN usr_crypto_ro;
    PRINT '✓ Usuário [usr_crypto_ro] criado no banco CryptoDB.';
END
GO

-- Concessão de permissões READ-ONLY
GRANT SELECT ON dbo.coins TO usr_crypto_ro;
GRANT SELECT ON dbo.price_history TO usr_crypto_ro;

PRINT '  ✓ SELECT concedido em todas as tabelas';
PRINT '  ✓ Usuário configurado para LEITURA APENAS';
GO