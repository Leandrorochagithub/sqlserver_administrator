SELECT 
    i.name,
    s.user_seeks,
    s.user_scans,
    s.last_user_seek
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id
--WHERE s.object_id = OBJECT_ID('dbo.price_history')
ORDER BY s.user_seeks DESC;