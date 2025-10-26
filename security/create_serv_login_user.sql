USE master;
GO

-- =====================================================
-- USUÁRIO DE SERVIÇO: ETL
-- Propósito: Alimentação automatizada do banco de dados
-- Nível de Privilégio: Leitura e Escrita (sem DELETE)
-- =====================================================

-- Verificar se o login já existe
IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = 'app_etl_crypto')
BEGIN
    -- IMPORTANTE: Substituir senha por variável segura em produção
    -- Usar SQL Server Configuration Manager ou Azure Key Vault
    CREATE LOGIN app_etl_crypto 
    WITH PASSWORD = N'$(ETL_PASSWORD)',  -- Variável SQLCMD
         CHECK_POLICY = ON,              -- Aplicar política de senha do Windows
         CHECK_EXPIRATION = ON;          -- Forçar expiração de senha
    
    PRINT 'Login [app_etl_crypto] criado com sucesso.';
END
ELSE
BEGIN
    PRINT 'Login [app_etl_crypto] já existe.';
END
GO

-- Mudar para o banco de dados alvo
USE CryptoDB;
GO

-- Verificar se o usuário já existe no banco
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'app_etl_crypto')
BEGIN
    CREATE USER app_etl_crypto FOR LOGIN app_etl_crypto;
    PRINT 'Usuário [app_etl_crypto] criado no banco CryptoDB.';
END
ELSE
BEGIN
    PRINT 'Usuário [app_etl_crypto] já existe no banco.';
END
GO

-- =====================================================
-- CONCESSÃO DE PERMISSÕES GRANULARES
-- =====================================================

PRINT 'Aplicando permissões para [app_etl_crypto]...';

-- PERMISSÃO BÁSICA DE CONEXÃO
GRANT CONNECT TO app_etl_crypto;

-- PERMISSÕES EM ESQUEMA (cobre objetos atuais e futuros)
GRANT SELECT, INSERT, UPDATE ON SCHEMA::dbo TO app_etl_crypto;
GRANT EXECUTE ON SCHEMA::dbo TO app_etl_crypto;
PRINT '✓ Permissões no schema dbo concedidas';

-- Permissões na tabela coins (moedas)
GRANT SELECT, INSERT, UPDATE ON dbo.coins TO app_etl_crypto;
GRANT EXECUTE ON dbo.coins TO app_etl_crypto;
PRINT 'SELECT, INSERT, UPDATE para dbo.coins';

-- Permissões na tabela price_history (histórico de preços)
GRANT SELECT, INSERT, UPDATE ON dbo.price_history TO app_etl_crypto;
PRINT 'SELECT, INSERT, UPDATE para dbo.price_history';

-- Negação explícita de DELETE (proteção contra deleções acidentais)
DENY DELETE ON dbo.coins TO app_etl_crypto;
DENY DELETE ON dbo.price_history TO app_etl_crypto;
PRINT 'DELETE NEGADO (proteção de dados)';

-- Negação explícita de permissões administrativas
DENY ALTER ANY SCHEMA TO app_etl_crypto;
DENY ALTER ANY USER TO app_etl_crypto;
DENY CONTROL TO app_etl_crypto;
PRINT 'Permissões administrativas NEGADAS';

GO

PRINT '========================================';
PRINT 'Modelo de segurança ETL configurado!';
PRINT '========================================';
