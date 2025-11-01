-- Verificar fragmentação antes da manutenção
SELECT 
    OBJECT_NAME(ips.object_id) AS table_name,
    i.name AS index_name,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count,
    CASE 
        WHEN ips.avg_fragmentation_in_percent < 10 THEN 'OK'
        WHEN ips.avg_fragmentation_in_percent < 30 THEN 'REORGANIZE'
        ELSE 'REBUILD'
    END AS action_needed
FROM sys.dm_db_index_physical_stats (
    DB_ID(), 
    NULL, 
    NULL, 
    NULL, 
    'LIMITED'
) AS ips
INNER JOIN sys.indexes AS i 
    ON ips.object_id = i.object_id 
    AND ips.index_id = i.index_id
WHERE ips.page_count > 100  -- Ignorar índices pequenos
ORDER BY ips.avg_fragmentation_in_percent DESC;