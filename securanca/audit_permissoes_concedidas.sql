-- Visualizar todas as permissões de um usuário
SELECT 
    USER_NAME(grantee_principal_id) AS username,
    OBJECT_NAME(major_id) AS object_name,
    permission_name,
    state_desc,  -- GRANT ou DENY
    CASE state_desc
        WHEN 'GRANT' THEN 'OK'
        WHEN 'DENY' THEN 'X'
    END AS status
FROM sys.database_permissions
WHERE grantee_principal_id IN (
    USER_ID('app_etl_crypto'),
    USER_ID('usr_crypto_ro')
)
AND major_id > 0  -- Apenas objetos (não permissões de banco)
ORDER BY username, object_name, permission_name;