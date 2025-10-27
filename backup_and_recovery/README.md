# 💾 Backup e Recuperação

## 📖 Visão Geral

Estratégia de backup implementada seguindo as melhores práticas para garantir recuperabilidade dos dados e minimizar perdas em caso de desastre.

### Objetivos de Recuperação

| Métrica | Objetivo | Descrição |
|---------|----------|-----------|
| **RPO** (Recovery Point Objective) | 15 minutos | Perda máxima de dados aceitável |
| **RTO** (Recovery Time Objective) | 2 horas | Tempo máximo para restauração completa |

### Recomendação: Estratégia 3-2-1

- ✅ **3** cópias dos dados (produção + 2 backups)
- ✅ **2** tipos de mídia diferentes (disco + rede/nuvem)
- ✅ **1** cópia offsite (fora do datacenter principal)

---

## 🗂️ Tipos de Backup

### 1. Backup Completo (Full)

**Script:** `full_backup.sql`

**Descrição:** Copia completa de todo o banco de dados, servindo como base para restaurações.

**Características:**
- Backup de todas as páginas de dados
- Não depende de backups anteriores
- Base para backups diferenciais e de log
- Maior tempo de execução e espaço em disco

**Frequência:** Semanal (Domingo às 09:00)

**Retenção:** 4 semanas (28 dias)

---

### 2. Backup Diferencial (Differential)

**Script:** `diff_backup.sql`

**Descrição:** Copia apenas as alterações desde o último backup completo.

**Características:**
- Backup incremental das mudanças
- Depende do último backup full
- Mais rápido que backup completo
- Crescimento cumulativo durante a semana

**Frequência:** Diário (Segunda a Sábado às 09:00)

**Retenção:** 7 dias
---

### 3. Backup de Log de Transação (Transaction Log)

**Script:** `log_backup.sql`

**Descrição:** Backup do log de transações para recuperação point-in-time.

**Características:**
- Permite recuperação para momento específico
- Mantém a cadeia de logs contínua
- Trunca o log após backup
- Menor impacto no sistema

**Frequência:** A cada 15 minutos (24/7)

**Retenção:** 48 horas
---

## 📁 Estrutura de Diretórios
```
E:\Backups\
├── Database\
│   ├── Full\              # Backups completos semanais
│   │   ├── NomeDoBanco_Full_2025-10-20-082648.bak
│   │   └── ...
│   └── Differential\      # Backups diferenciais diários
│       ├── NomeDoBanco_Diff_2025-10-26-080030.bak
│       ├── NomeDoBanco_Diff_2025-10-25-080230.bak
│       └── ...
└── Log\                   # Backups de log (15 em 15 min)
    ├── NomeDoBanco_Log_2025-10-26_143005.trn
    ├── NomeDoBanco_Log_2025-10-26_141505.trn
    └── ...
```

<img width="1800" height="115" alt="pasta_backup_database" src="https://github.com/user-attachments/assets/2186af8f-8e13-4658-8296-b7f1953a7c79" />

<img width="1800" height="115" alt="pasta_backup_log" src="https://github.com/user-attachments/assets/b330f2f2-73f3-4c21-a697-61e58ff5dd6b" />

---

## 🔄 Restauração de Banco de Dados

### 4. Procedimento de Restore

**Arquivo:** `restore_database.sql`

**Cenários de Restauração:**

#### 4.1. Restauração Completa (Desastre Total)

**Situação:** Banco de dados corrompido ou completamente perdido.

**Passos:**

1. **Identificar a corrupção:**
```sql
-- Verificar estado do banco
SELECT name, state_desc, user_access_desc
FROM sys.databases
WHERE name = 'CryptoDB';

-- Executar DBCC para verificar consistência
DBCC CHECKDB ('CryptoDB') WITH NO_INFOMSGS;
```

<img width="1800" height="600" alt="corrompimento" src="https://github.com/user-attachments/assets/80a37761-899c-44e0-a00b-958129403d02" />
<br>
<br>

2. **Fazer backup de tail-log (se possível):**
```sql
-- Backup do tail do log (últimas transações)
BACKUP LOG CryptoDB
TO DISK = 'E:\Backups\Log\CryptoDB_TailLog.trn'
WITH NO_TRUNCATE, NORECOVERY;
```

3. **Colocar banco offline:**
```sql
ALTER DATABASE CryptoDB SET OFFLINE WITH ROLLBACK IMMEDIATE;
```

4. **Restaurar backup full:**
```sql
-- Restaurar backup completo mais recente
RESTORE DATABASE CryptoDB
FROM DISK = 'E:\Backups\Database\Full\CryptoDB_Full_20251020.bak'
WITH 
    NORECOVERY,  -- Permite aplicar mais backups, sem finalizer o processo de restore
    REPLACE,      -- Sobrescreve banco existente
    STATS = 10;
GO
```

5. **Restaurar backup diferencial:**
 ```sql
-- Restaurar último backup diferencial
RESTORE DATABASE [NomeDoBanco]
FROM DISK = 'E:\Backups\Database\Differential\NomeDoBanco_Diff_20251026.bak'
WITH 
    NORECOVERY,
    STATS = 10;
GO
```

6. **Restaurar backups de log em sequência:**
```sql
-- Restaurar todos os logs de transação desde o diferencial
RESTORE LOG CryptoDB
FROM DISK = 'E:\Backups\Log\CryptoDB_Log_20251026_0800.trn'
WITH NORECOVERY;
GO

RESTORE LOG CryptoDB
FROM DISK = 'E:\Backups\Log\CryptoDB_Log_20251026_0815.trn'
WITH NORECOVERY;
GO

-- ... continuar com todos os arquivos .trn ...

-- Último log (tail-log) e finalizar restore
RESTORE LOG CryptoDB
FROM DISK = 'E:\Backups\Log\CryptoDB_TailLog.trn'
WITH RECOVERY;  -- Finaliza e deixa banco online
GO
```

7. **Verificar integridade após restore:**
```sql
-- Verificar consistência do banco restaurado
DBCC CHECKDB ('CryptoDB') WITH NO_INFOMSGS;

-- Verificar estado do banco
SELECT name, state_desc, recovery_model_desc
FROM sys.databases
WHERE name = 'CryptoDB';

-- Testar consultas
SELECT TOP 10 * FROM [CryptoDB].[dbo].[Coins];
```
<img width="1800" height="400" alt="RESTORE_P2" src="https://github.com/user-attachments/assets/d3ce8a71-c1c2-451e-a034-7e7b52e7e7ca" />
<img width="1800" height="600" alt="Captura de tela 2025-10-26 094458" src="https://github.com/user-attachments/assets/8ff3d022-4fb5-4643-8fcc-11ec4a5fb920" />

#### 4.2. Restauração Point-in-Time

**Situação:** Reverter para um momento específico antes de erro humano/lógico (se necessário)
```sql
-- Restaurar até momento específico (ex: antes de DELETE acidental)
RESTORE DATABASE CryptoDB
FROM DISK = 'E:\Backups\Database\Full\CryptoDB_Full_20251020.bak'
WITH NORECOVERY, REPLACE;

RESTORE DATABASE CryptoDB
FROM DISK = 'E:\Backups\Database\Differential\CryptoDB_Diff_20251026.bak'
WITH NORECOVERY;

-- Restaurar logs até horário específico
RESTORE LOG CryptoDB
FROM DISK = 'E:\Backups\Log\CryptoDB_Log_20251026_1400.trn'
WITH RECOVERY, STOPAT = '2025-10-26 14:25:00';
GO
```

---

## 🤖 Automação com SQL Server Agent Jobs

### 5. Configuração de Jobs Automáticos

**Objetivo:** Executar backups automaticamente sem intervenção manual.

<img width="1800" height="300" alt="Captura de tela 2025-10-08 154643" src="https://github.com/user-attachments/assets/e9a0b087-3bb4-45ac-a83a-55c3c0ff1a3a" />

#### 5.1. Job: Backup Full Semanal

**Nome:** `DBA - Backup Full Semanal`

**Schedule:** Domingo, 09:00

**Passos:**
1. Verificar espaço em disco (> 50 GB livre)
2. Executar `full_backup.sql`
3. Verificar integridade do backup
4. Enviar notificação por email
5. Limpar backups antigos (> 28 dias)

**Exemplo de código do Job:**
```sql
USE [msdb];
GO

EXEC msdb.dbo.sp_add_job
    @job_name = N'DBA - Backup Full Semanal',
    @enabled = 1,
    @description = N'Backup completo executado semanalmente';

EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'DBA - Backup Full Semanal',
    @step_name = N'Executar Backup Full',
    @subsystem = N'TSQL',
    @command = N'EXEC [dbo].[usp_ExecutarBackupFull]',
    @database_name = N'master',
    @retry_attempts = 2,
    @retry_interval = 5;

EXEC msdb.dbo.sp_add_jobschedule
    @job_name = N'DBA - Backup Full Semanal',
    @name = N'Semanal_Domingo_09h',
    @freq_type = 8,  -- Semanal
    @freq_interval = 1,  -- Domingo
    @active_start_time = 090000;  -- 09:00:00
GO
```

#### 5.2. Job: Backup Diferencial Diário

**Nome:** `DBA - Backup Diferencial Diário`

**Schedule:** Segunda a Sábado, 09:00

**Exemplo de código do Job:**
```sql
EXEC msdb.dbo.sp_add_job
    @job_name = N'DBA - Backup Diferencial Diário';

EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'DBA - Backup Diferencial Diário',
    @step_name = N'Executar Backup Diferencial',
    @command = N'EXEC [dbo].[usp_ExecutarBackupDiferencial]';

EXEC msdb.dbo.sp_add_jobschedule
    @job_name = N'DBA - Backup Diferencial Diário',
    @name = N'Diario_SegASab_09h',
    @freq_type = 8,  -- Semanal
    @freq_interval = 126,  -- Seg a Sáb (2+4+8+16+32+64)
    @active_start_time = 090000;
GO
```

#### 5.3. Job: Backup de Log (15 em 15 minutos)

**Nome:** `DBA - Backup Log Transaction`

**Schedule:** Diário, a cada 15 minutos

**Exemplo de código do Job:**
```sql
EXEC msdb.dbo.sp_add_job
    @job_name = N'DBA - Backup Log Transaction';

EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'DBA - Backup Log Transaction',
    @step_name = N'Executar Backup Log',
    @command = N'EXEC [dbo].[usp_ExecutarBackupLog]';

EXEC msdb.dbo.sp_add_jobschedule
    @job_name = N'DBA - Backup Log Transaction',
    @name = N'A_cada_15_minutos',
    @freq_type = 4,  -- Diário
    @freq_interval = 1,
    @freq_subday_type = 4,  -- Minutos
    @freq_subday_interval = 15;
GO
```

#### 5.4. Job: Limpeza de Backups Antigos

**Nome:** `DBA - Limpeza Backups Antigos`

**Schedule:** Diário, 04:00

**Retenção:**
- Full: 28 dias
- Diferencial: 7 dias
- Log: 2 dias

---

## 📊 Monitoramento e Validação

### Verificar Histórico de Backups

**Arquivo:** `audit_historico_backup.sql`

<img width="1800" height="400" alt="Captura de tela 2025-10-26 163548" src="https://github.com/user-attachments/assets/d9bc82ce-c0be-4439-87e5-32125ed19aa4" />

### Dashboard de Monitoramento

**Arquivo:** `audit_monitoramento_backup.sql`

<img width="1800" height="300" alt="Captura de tela 2025-10-26 101024" src="https://github.com/user-attachments/assets/c952e346-0d8f-4fcb-8564-c51bfc4f71aa" />

### Testar Restauração (Drill Test)

**Frequência recomendada:** Mensal
```sql
-- Procedimento de teste de restauração
-- 1. Criar banco de teste
-- 2. Restaurar último backup
-- 3. Verificar integridade
-- 4. Validar dados
-- 5. Remover banco de teste
-- 6. Documentar resultado
```

---

## ⚠️ Troubleshooting

### Problema: Backup de log falhando

**Erro:** `The log or differential backup cannot be taken because no files are ready for rollover`

**Solução:**
```sql
-- Verificar modelo de recuperação
SELECT name, recovery_model_desc 
FROM sys.databases 
WHERE name = 'CryptoDB';

-- Se SIMPLE, alterar para FULL
ALTER DATABASE CryptoDB SET RECOVERY FULL;

-- Executar backup full antes do log
BACKUP DATABASE CryptoDB TO DISK = '...';
```

### Problema: Espaço insuficiente

**Monitorar espaço em disco:**
```sql
EXEC xp_fixeddrives;  -- Espaço livre em cada drive
```

**Soluções:**
1. Aumentar período de retenção
2. Habilitar compressão (já habilitado)
3. Mover backups antigos para storage secundário
4. Adicionar mais espaço em disco

### Problema: Backup muito lento

**Otimizações:**
1. Usar COMPRESSION (já implementado)
2. Aumentar BUFFERCOUNT e MAXTRANSFERSIZE
3. Fazer backup em horários de baixo uso
4. Usar múltiplos arquivos de backup
```sql
-- Backup com otimização
BACKUP DATABASE CryptoDB
TO DISK = 'E:\Backups\File1.bak',
   DISK = 'E:\Backups\File2.bak',
   DISK = 'E:\Backups\File3.bak'
WITH 
    COMPRESSION,
    BUFFERCOUNT = 50,
    MAXTRANSFERSIZE = 4194304;  -- 4 MB
```

---

## 📋 Checklist de Manutenção

### Diário
- [ ] Verificar execução dos jobs de backup
- [ ] Confirmar espaço em disco disponível (> 30%)
- [ ] Revisar logs de erro do SQL Server Agent

### Semanal
- [ ] Validar integridade dos backups full
- [ ] Revisar tamanho dos arquivos de backup
- [ ] Verificar cadeia de backups de log

### Mensal
- [ ] Executar teste de restauração completo
- [ ] Revisar política de retenção
- [ ] Auditar permissões de acesso aos backups
- [ ] Documentar tempo de restore (RTO real)

### Trimestral
- [ ] Revisar e atualizar documentação
- [ ] Testar restore em servidor secundário
- [ ] Validar cópias offsite
- [ ] Revisar capacidade de storage

---

## 📚 Referências

- [SQL Server Backup and Restore - Microsoft Docs](https://docs.microsoft.com/sql/relational-databases/backup-restore/)
- [Recovery Models - Microsoft Docs](https://docs.microsoft.com/sql/relational-databases/backup-restore/recovery-models-sql-server)
- [Best Practices for SQL Server Backup](https://www.brentozar.com/sql-server-backup-best-practices/)

