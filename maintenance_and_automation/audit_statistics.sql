-- Ver quando estatísticas foram atualizadas
SELECT 
    OBJECT_NAME(s.object_id) AS table_name,
    s.name AS stats_name,
    STATS_DATE(s.object_id, s.stats_id) AS last_updated,
    DATEDIFF(DAY, STATS_DATE(s.object_id, s.stats_id), GETDATE()) AS days_old,
    CASE 
        WHEN DATEDIFF(DAY, STATS_DATE(s.object_id, s.stats_id), GETDATE()) > 7 
        THEN 'DESATUALIZADA'
        ELSE 'OK'
    END AS status
FROM sys.stats s
WHERE STATS_DATE(s.object_id, s.stats_id) IS NOT NULL
ORDER BY last_updated ASC;