USE master
GO

-- Listar todos os logins da inst�ncia
SELECT 
    name AS login_name,
    type_desc AS authentication_type,
    create_date,
    modify_date,
    is_disabled,
    CASE 
        WHEN is_policy_checked = 1 THEN 'Pol�tica ativa'
        ELSE 'Sem pol�tica'
    END AS password_policy
FROM sys.sql_logins
WHERE name IN ('app_etl_crypto', 'usr_crypto_ro')
ORDER BY create_date DESC;

USE CryptoDB;
GO

-- Listar usu�rios do banco
SELECT 
    dp.name AS username,
    dp.type_desc AS principal_type,
    dp.create_date,
    sp.name AS associated_login
FROM sys.database_principals dp
LEFT JOIN sys.server_principals sp ON dp.sid = sp.sid
WHERE dp.name IN ('app_etl_crypto', 'usr_crypto_ro');
