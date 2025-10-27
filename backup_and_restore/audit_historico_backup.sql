-- Últimos backups realizados
SELECT 
    database_name,
    type,
    CASE type
        WHEN 'D' THEN 'Full'
        WHEN 'I' THEN 'Differential'
        WHEN 'L' THEN 'Log'
    END AS backup_type,
    backup_start_date,
    backup_finish_date,
    DATEDIFF(MINUTE, backup_start_date, backup_finish_date) AS duration_minutes,
    CAST(backup_size / 1024.0 / 1024.0 / 1024.0 AS DECIMAL(10,2)) AS size_gb,
    CAST(compressed_backup_size / 1024.0 / 1024.0 / 1024.0 AS DECIMAL(10,2)) AS compressed_size_gb,
    physical_device_name
FROM msdb.dbo.backupset bs
JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE database_name = 'CryptoDB'
    AND backup_start_date >= DATEADD(DAY, -7, GETDATE())
ORDER BY backup_start_date DESC;