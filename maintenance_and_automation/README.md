# 🔧 Manutenção Preventiva

## 📖 Visão Geral

Estratégia de manutenção preventiva automatizada para garantir performance, integridade e confiabilidade do banco de dados ao longo do tempo.

### Por que Manutenção é Crítica?

Com o uso contínuo (milhares de operações DML diárias), o banco de dados sofre degradação natural:

| Problema | Causa | Impacto | Solução |
|----------|-------|---------|---------|
| **Fragmentação de Índices** | INSERT/UPDATE/DELETE desordenam páginas de dados | Lentidão em consultas (até 300% mais lentas) | Rebuild/Reorganize Indexes |
| **Estatísticas Desatualizadas** | Otimizador usa informações antigas | Planos de execução ineficientes | Update Statistics |
| **Corrupção de Dados** | Falhas de hardware/software silenciosas | Perda de dados, crashes | DBCC CHECKDB |

### 📊 Impacto da Fragmentação
```
Fragmentação 0-10%     → Performance ótima ✅
Fragmentação 10-30%    → Performance aceitável ⚠️
Fragmentação 30-60%    → Degradação notável 🟡
Fragmentação >60%      → Performance crítica 🔴
```

---

## 🛠️ Implementação

### Ferramenta Utilizada

**SQL Server Maintenance Plans** (GUI integrada ao SQL Server Management Studio)

**Vantagens:**
- ✅ Interface visual intuitiva
- ✅ Agendamento nativo via SQL Server Agent
- ✅ Logging automático
- ✅ Notificações por email
- ✅ Fácil manutenção

---

## 📋 Tarefas de Manutenção

### 1️⃣ Verificação de Integridade (DBCC CHECKDB)

#### Objetivo
Detectar corrupção de dados no nível físico e lógico antes que cause falhas em produção.

#### O que verifica
- ✅ Consistência de páginas de dados
- ✅ Integridade de índices (clustered e non-clustered)
- ✅ Links entre páginas
- ✅ Estruturas de alocação (GAM, SGAM, PFS)
- ✅ Validação de checksum

#### Quando executar
- **Obrigatório:** Semanal para bancos críticos
- **Recomendado:** Antes de backups importantes
- **Crítico:** Após falhas de hardware ou quedas de energia

#### Comando Equivalente
```sql
-- Executado pelo Maintenance Plan
DBCC CHECKDB (N'CryptoDB') 
WITH NO_INFOMSGS, 
     ALL_ERRORMSGS,
     DATA_PURITY;
```

#### Tempo de Execução Esperado
- Banco < 10 GB: ~2-5 minutos
- Banco 10-100 GB: ~10-30 minutos
- Banco > 100 GB: ~1-3 horas

⚠️ **Impacto:** Pode causar bloqueios de leitura (schema locks). Executar fora do horário de pico.

#### Interpretação de Resultados

**✅ Sucesso:**
```
CHECKDB found 0 allocation errors and 0 consistency errors in database 'CryptoDB'.
```

**❌ Corrupção Detectada:**
```
Msg 8928: Object ID 245575913, index ID 1, partition ID 72057594038321152, 
alloc unit ID 72057594043498496 (type In-row data): Page (1:156) could not be processed.
```

**Ação:** Restaurar do último backup válido + aplicar logs de transação.

---

### 2️⃣ Reorganização/Reconstrução de Índices

#### Objetivo
Eliminar fragmentação para melhorar performance de leitura e escrita.

#### Estratégia Inteligente

| Fragmentação | Ação | Comando | Online? | Tempo |
|--------------|------|---------|---------|-------|
| 0-10% | ✅ Nenhuma | - | - | - |
| 10-30% | 🔄 REORGANIZE | `ALTER INDEX REORGANIZE` | Sim | Rápido |
| >30% | 🔨 REBUILD | `ALTER INDEX REBUILD` | Não* | Lento |

#### Configuração do Maintenance Plan

**Opções recomendadas:**
- ✅ **Alterar espaço livre por página para:** 10%
  - Deixa espaço para futuros INSERTs/UPDATEs
  - Reduz fragmentação rápida
  
- ✅ **Mantenha o índice online durante a reindexação:** ☑️
  - Permite consultas durante rebuild
  - Usa mais recursos temporários

- ✅ **Classificar resultados em tempdb:** ☑️
  - Protege o log de transação
  - Requer espaço em tempdb

#### Comando Equivalente
```sql
-- Reorganize (fragmentação 10-30%)
ALTER INDEX ALL ON dbo.price_history REORGANIZE;

-- Rebuild (fragmentação >30%)
ALTER INDEX ALL ON dbo.price_history REBUILD 
WITH (
    FILLFACTOR = 90,           -- 10% de espaço livre
    SORT_IN_TEMPDB = ON,       -- Usar tempdb
    STATISTICS_NORECOMPUTE = OFF,
    ONLINE = ON                -- Requer Enterprise
);
```

#### Script de Análise de Fragmentação

**Arquivo**: `audit_dbfragmentation.sql`

<img width="1800" height="300" alt="Captura de tela 2025-10-26 170748" src="https://github.com/user-attachments/assets/86602fa3-602d-4b30-81e6-c38ba95b6cee" />

---


### 3️⃣ Atualização de Estatísticas

#### Objetivo
Fornecer ao Query Optimizer informações atualizadas sobre distribuição de dados para gerar planos de execução eficientes.

#### O que são Estatísticas?

Histogramas que descrevem:
- Distribuição de valores em colunas
- Densidade de dados
- Número de linhas
- Cardinalidade

**Exemplo:** Sem estatísticas atualizadas, o otimizador pode usar um Index Scan (lento) quando um Index Seek (rápido) seria mais eficiente.

#### Quando Atualizar
- ✅ Após grandes cargas de dados (ETL)
- ✅ Após rebuild de índices
- ✅ Semanalmente em tabelas com alta rotatividade
- ✅ Quando planos de execução estão subótimos

#### Configuração do Maintenance Plan

**Opções:**
- **Update statistics:** All existing statistics
- **Scan type:** Full Scan (mais preciso, mais lento)
  - Sample: Rápido mas menos preciso
  - Full: Lento mas 100% preciso

#### Comando Equivalente
```sql
-- Atualizar estatísticas de todas as tabelas
UPDATE STATISTICS dbo.coins WITH FULLSCAN;
UPDATE STATISTICS dbo.price_history WITH FULLSCAN;

-- Ou para todo o banco
EXEC sp_updatestats;
```

#### Script de Verificação

**Arquivo:** `audit_statistics.sql`

<img width="1800" height="500" alt="Captura de tela 2025-10-26 171154" src="https://github.com/user-attachments/assets/1ef6be6d-d8bd-4b00-862f-81bf66471fb1" />

## 📅 Cronograma de Manutenção

### Configuração do Maintenance Plan

**Nome:** `DBA - CryptoDBWeeklyMaintenance_Subplan_1`

**Frequência:** Semanal

**Janela de Manutenção:** ~ 4 horas

**Sequência de Execução:**
```
1. DBCC CHECKDB      
2. Rebuild Indexes   
3. Update Statistics 
4. Limpeza de Logs   
```

## 🎨 Configuração Visual do Maintenance Plan

### Tarefas Agendadas: 

* 1º: 🔍 Verificação de Integridade (Check Database Integrity - DBCC CHECKDB)
* 2º: 🔨 Reconstruir Índices (Rebuild Index)
* 3º: 📊 Atualizar Estatísticas (Update Statistics)
* Retenção: 7 dias

### Maintenance Plan:

<img width="1800" height="500" alt="Captura de tela 2025-10-10 145946" src="https://github.com/user-attachments/assets/3bb5450e-a22b-40c5-8990-9b47cfaf73df" />
<img width="1800" height="500" alt="Captura de tela 2025-10-10 150210" src="https://github.com/user-attachments/assets/32feaf62-3347-4a91-9c6e-40a99bd5c94e" />

### Execução:
**Executando...**

<img width="1800" height="500" alt="Captura de tela 2025-10-10 154642" src="https://github.com/user-attachments/assets/f205470a-fe36-43af-809e-9df16563e5c5" />


**Arquivo que Log direcionando para pasta específica:**

<img width="1800" height="500" alt="Captura de tela 2025-10-26 172423" src="https://github.com/user-attachments/assets/db1d66d6-4e50-4954-8110-30fd7c44577e" />

---

### Interpretar Logs

#### ✅ Execução Bem-Sucedida
```
Microsoft(R) SQL Server Maintenance Plan
Duration: 01:45:32

Task: Check Database Integrity
Status: Success
Duration: 00:28:15
Message: DBCC CHECKDB (CryptoDB) executed without errors.

Task: Rebuild Index
Status: Success  
Duration: 01:02:44
Message: Rebuilding indexes on [dbo].[price_history]...
         Index [IX_price_history_coin_date] fragmentation: 62.4% → 0.2%

Task: Update Statistics
Status: Success
Duration: 00:14:33
Message: Statistics updated for [dbo].[coins], [dbo].[price_history]
```

#### ❌ Execução com Falhas
```
Task: Check Database Integrity
Status: Failed
Duration: 00:05:12
Message: Msg 8928, Level 16, State 1
         Object ID 245575913: Page (1:156) could not be processed.
         See previous errors.
         
Action Required: Restore database from last known good backup.
```

#### Dashboard de Saúde do Banco

**Arquivo:** `audit_CryptoDBWeeklyMaintenance_Subplan_1.sql`

<img width="1800" height="300" alt="Captura de tela 2025-10-26 173411" src="https://github.com/user-attachments/assets/d64d3084-3a2f-48ae-9cce-29623cfbc73c" />

---

## ⚠️ Impacto e Considerações

### Impacto no Usuário Final

| Tarefa | Impacto | Bloqueio? | Mitigação |
|--------|---------|-----------|-----------|
| DBCC CHECKDB | Baixo | Schema lock (leitura permitida) | Executar em horário de baixo uso |
| REORGANIZE | Baixo | Online | Pode executar a qualquer momento |
| REBUILD (Standard) | **Alto** | Offline (bloqueio total) | Janela de manutenção obrigatória |
| REBUILD (Enterprise + ONLINE) | Médio | Online (bloqueios mínimos) | Preferir esta opção |
| UPDATE STATISTICS | Baixo | Mínimo | Rápido, baixo impacto |

### Requisitos de Recursos

**Espaço em Disco:**
- Rebuild: ~1.5x tamanho do índice em tempdb
- CHECKDB: Snapshot interno (copy-on-write)

**Memória:**
- Rebuild: Buffer pool intensivo
- CHECKDB: Pode usar até 25% da memória disponível

**CPU:**
- Todas as tarefas são CPU-intensivas
- Pode afetar outras cargas de trabalho

### Recomendações

✅ **Para bancos pequenos (<50 GB):**
- Executar tudo semanalmente
- Usar REBUILD sempre

✅ **Para bancos médios (50-500 GB):**
- CHECKDB: Semanal
- Rebuild: Apenas índices >30% fragmentados
- Reorganize: Índices 10-30% fragmentados

✅ **Para bancos grandes (>500 GB):**
- CHECKDB: Mensal (ou incremental)
- Rebuild: Seletivo por partição
- Considerar Ola Hallengren scripts

---

## 🐛 Troubleshooting

### Problema: Manutenção está demorando muito

**Sintomas:**
- Job excede janela de manutenção
- Timeout errors
- Bloqueios prolongados

**Diagnóstico:**
```sql
-- Ver progresso do DBCC CHECKDB
SELECT 
    session_id,
    command,
    percent_complete,
    estimated_completion_time,
    DATEADD(ms, estimated_completion_time, GETDATE()) AS estimated_finish_time
FROM sys.dm_exec_requests
WHERE command LIKE '%DBCC%';
```

**Soluções:**
1. Dividir grandes tabelas em partições
2. Usar REORGANIZE em vez de REBUILD quando possível
3. Aumentar janela de manutenção
4. Usar `DBCC CHECKDB WITH PHYSICAL_ONLY` (mais rápido)

### Problema: Espaço insuficiente em tempdb

**Erro:**
```
Could not allocate space for object in database 'tempdb'
```

**Soluções:**
```sql
-- Verificar espaço em tempdb
SELECT 
    name,
    size * 8.0 / 1024 AS size_mb,
    max_size * 8.0 / 1024 AS max_size_mb
FROM tempdb.sys.database_files;

-- Expandir tempdb
ALTER DATABASE tempdb 
MODIFY FILE (NAME = tempdev, SIZE = 10GB, MAXSIZE = 50GB);
```

### Problema: Job falha com erro de permissão

**Erro:**
```
The EXECUTE permission was denied on the object 'sp_start_job'
```

**Solução:**
```sql
-- Adicionar SQL Agent service account às roles necessárias
USE msdb;
EXEC sp_addrolemember @rolename = 'SQLAgentOperatorRole', 
                      @membername = 'DOMAIN\SQLAgentService';
```

---

### KPIs de Manutenção

**Arquivo:** `audit_maintenance_kpi.sql`

<img width="1800" height="300" alt="Captura de tela 2025-10-26 174103" src="https://github.com/user-attachments/assets/8dfa714c-c6be-42a5-8143-cda4259b7405" />

### Metas

| Métrica | Meta | Status |
|---------|------|--------|
| **Taxa de Sucesso** | >95% | ✅ 98% |
| **Duração Média** | <3 horas | ✅ 1h 45min |
| **Fragmentação Média** | <10% | ✅ 4.2% |
| **Estatísticas Atualizadas** | 100% | ✅ 100% |
| **Corrupção Detectada** | 0 | ✅ 0 |

---

## 📋 Checklist de Manutenção

### Pré-Execução (Quinzenal)
- [ ] Verificar espaço em disco (>30% livre)
- [ ] Verificar espaço em tempdb (>50 GB livre)
- [ ] Validar janela de manutenção adequada
- [ ] Confirmar backup recente disponível

### Pós-Execução (Segunda-feira)
- [ ] Revisar log de execução
- [ ] Verificar status de todas as tarefas
- [ ] Confirmar fragmentação reduzida (<10%)
- [ ] Validar estatísticas atualizadas
- [ ] Arquivar logs antigos (>30 dias)

### Mensal
- [ ] Analisar tendência de duração
- [ ] Revisar taxa de sucesso
- [ ] Avaliar necessidade de ajustes no plano
- [ ] Documentar incidentes e resoluções

---

### Documentação Microsoft

- [Maintenance Plans - Microsoft Docs](https://docs.microsoft.com/sql/relational-databases/maintenance-plans/maintenance-plans)
- [DBCC CHECKDB - Microsoft Docs](https://docs.microsoft.com/sql/t-sql/database-console-commands/dbcc-checkdb-transact-sql)
- [ALTER INDEX - Microsoft Docs](https://docs.microsoft.com/sql/t-sql/statements/alter-index-transact-sql)

---
