SELECT 
    'Última Manutenção' AS metric,
    MAX(h.run_date) AS value
FROM msdb.dbo.sysjobhistory h
WHERE h.job_id = (
    SELECT job_id FROM msdb.dbo.sysjobs 
    WHERE name = 'DBA - CryptoDBWeeklyMaintenance.Subplan_1'
)

UNION ALL

SELECT 
    'Fragmentação Média (%)',
    CAST(AVG(ips.avg_fragmentation_in_percent) AS VARCHAR)
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
--WHERE ips.page_count > 100

UNION ALL

SELECT 
    'Estatísticas Desatualizadas',
    COUNT(*)
FROM sys.stats s
WHERE DATEDIFF(DAY, STATS_DATE(s.object_id, s.stats_id), GETDATE()) > 7;