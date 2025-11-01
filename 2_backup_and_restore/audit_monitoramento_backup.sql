-- Status geral dos backups
WITH LastBackups AS (
    SELECT 
        database_name,
        type,
        MAX(backup_finish_date) AS last_backup_date,
        MAX(backup_size) AS last_size
    FROM msdb.dbo.backupset
    WHERE backup_finish_date >= DATEADD(DAY, -30, GETDATE())
    GROUP BY database_name, type
)
SELECT 
    d.name AS database_name,
    d.recovery_model_desc,
    lb_full.last_backup_date AS last_full_backup,
    DATEDIFF(DAY, lb_full.last_backup_date, GETDATE()) AS days_since_full,
    lb_diff.last_backup_date AS last_diff_backup,
    DATEDIFF(HOUR, lb_diff.last_backup_date, GETDATE()) AS hours_since_diff,
    lb_log.last_backup_date AS last_log_backup,
    DATEDIFF(MINUTE, lb_log.last_backup_date, GETDATE()) AS minutes_since_log,
    CASE 
        WHEN lb_full.last_backup_date IS NULL THEN 'B_CRÍTICO'
        WHEN DATEDIFF(DAY, lb_full.last_backup_date, GETDATE()) > 7 THEN 'B_ATENÇÃO'
        WHEN lb_log.last_backup_date IS NULL THEN 'L_CRÍTICO'
        WHEN DATEDIFF(MINUTE, lb_log.last_backup_date, GETDATE()) > 30 THEN 'L_ATENÇÃO'
        ELSE 'OK'
    END AS status
FROM sys.databases d
LEFT JOIN LastBackups lb_full ON d.name = lb_full.database_name AND lb_full.type = 'D'
LEFT JOIN LastBackups lb_diff ON d.name = lb_diff.database_name AND lb_diff.type = 'I'
LEFT JOIN LastBackups lb_log ON d.name = lb_log.database_name AND lb_log.type = 'L'
WHERE d.database_id > 4  -- Excluir bancos de sistema
ORDER BY d.name;