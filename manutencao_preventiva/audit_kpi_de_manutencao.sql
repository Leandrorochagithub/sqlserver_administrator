-- Dashboard mensal de manutenção
WITH MaintenanceStats AS (
    SELECT 
        DATEFROMPARTS(run_date/10000, (run_date%10000)/100, run_date%100) AS execution_date,
        CASE run_status 
            WHEN 1 THEN 'Success'
            ELSE 'Failed'
        END AS status,
        run_duration
    FROM msdb.dbo.sysjobhistory
    WHERE job_id = (
        SELECT job_id FROM msdb.dbo.sysjobs 
        WHERE name = 'DBA - CryptoDBWeeklyMaintenance.Subplan_1'
    )
    AND DATEFROMPARTS(run_date/10000, (run_date%10000)/100, run_date%100) 
        >= DATEADD(MONTH, -1, GETDATE())
)
SELECT 
    COUNT(*) AS total_executions,
    SUM(CASE WHEN status = 'Success' THEN 1 ELSE 0 END) AS successful,
    SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END) AS failed,
    CAST(AVG(CAST(run_duration AS FLOAT)) / 10000 AS DECIMAL(10,2)) AS avg_duration_hours,
    CAST(100.0 * SUM(CASE WHEN status = 'Success' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS success_rate_percent
FROM MaintenanceStats;