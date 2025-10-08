# Backup e Recuperação: Estratégia de backup para garantir a recuperabilidade dos dados e minimizar a perda em caso de desastre (RPO/RTO)

**1. full_backup.sql: Backup completo**

**2. diff_backup.sql: Backup incremental**

**3. log_backup.sql: Backup de log de transação**
<br>
<br>
<img width="767" height="113" alt="pasta_backup_database" src="https://github.com/user-attachments/assets/2186af8f-8e13-4658-8296-b7f1953a7c79" />
<img width="761" height="36" alt="pasta_backup_log" src="https://github.com/user-attachments/assets/b330f2f2-73f3-4c21-a697-61e58ff5dd6b" />

**4. restore_database.sql: Execução de restore do banco corrompido**

* Corrompido:
<br>
<img width="1602" height="610" alt="corrompimento" src="https://github.com/user-attachments/assets/80a37761-899c-44e0-a00b-958129403d02" />
<br>
<br>

* Recuperado:
<br>
<img width="1607" height="382" alt="RESTORE_P2" src="https://github.com/user-attachments/assets/d3ce8a71-c1c2-451e-a034-7e7b52e7e7ca" />
<br>
<br>

**5. Plano automação de backups com Jobs dentro do Sql Server**

