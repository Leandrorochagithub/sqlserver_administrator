-- Verificar última alteração de senha
SELECT 
    name,
    create_date,
    modify_date,
    DATEDIFF(DAY, modify_date, GETDATE()) AS days_since_password_change
FROM sys.sql_logins
WHERE name = 'app_etl_crypto' OR name = 'usr_crypto_ro';