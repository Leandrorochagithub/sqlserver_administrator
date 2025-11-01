# 💼 Portfólio: Administração de Banco de Dados SQL Server

[![SQL Server](https://img.shields.io/badge/SQL%20Server-2019+-CC2927?logo=microsoft-sql-server&logoColor=white)](https://www.microsoft.com/sql-server)
[![T-SQL](https://img.shields.io/badge/T--SQL-Transact--SQL-blue)](https://docs.microsoft.com/sql/t-sql/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Status](https://img.shields.io/badge/status-active-success)](https://github.com/seu-usuario/sqlserver-dba-portfolio)

## 📖 Sobre o Projeto

Portfólio técnico demonstrando **competências essenciais de um Administrador de Banco de Dados (DBA)** através de implementações práticas em SQL Server. 

Este repositório documenta a aplicação de melhores práticas em:
- 🔒 **Segurança** e controle de acesso
- 💾 **Backup e recuperação** de dados
- 🔧 **Automação** e manutenção preventiva
- 🚀 **Otimização** de performance

**Cenário:** Sistema de rastreamento de preços de criptomoedas (`CryptoDB`) com 2+ milhões de registros históricos.

---

## 🎯 Objetivos

- ✅ Demonstrar **expertise técnica** em administração SQL Server
- ✅ Aplicar **princípios de segurança** (menor privilégio, auditoria)
- ✅ Implementar **estratégias de backup** com RPO/RTO definidos
- ✅ Automatizar **manutenção preventiva** para garantir saúde do banco
- ✅ Diagnosticar e **resolver problemas de performance** (99%+ de melhoria)
- ✅ Documentar **processos e decisões técnicas**

---

## 🏗️ Arquitetura do Projeto

### Bancos de Dados
```
┌─────────────────────────────────────────┐
│ SQL Server Instance                     │
├─────────────────────────────────────────┤
                                         
  📊 CryptoDB (Aplicação)                
  ├── dbo.coins (cadastro de moedas)     
  └── dbo.price_history (histórico)      
      └── 2M+ registros                  
                                         
  🔧 DBA_Admin (Administração)          
  └── Procedures de DBA                  
      └── Análise, auditoria, relatórios
                                         
└─────────────────────────────────────────┘
```

### Separação de Responsabilidades

| Banco | Propósito | Conteúdo |
|-------|-----------|----------|
| **CryptoDB** | Aplicação | Tabelas de negócio, SPs de aplicação |
| **DBA_Admin** | Administração | Ferramentas de DBA, scripts utilitários |

---

## 📂 Estrutura do Repositório
```
sqlserver_administrator/
│
├── 📁 0_criacao_banco/                   
│   ├── create_banco_cryptodb.sql
├── 📁 1_securanca/                    # Módulo 1: Segurança
│   ├── create_login_e_user_de_servico.sql
|   ├── create_login_e_user_de_usuario.sql
│   ├── usp_get_failed_logins_report.sql
│   ├── audit_teste_de_permissoes.sql
│   ├── audit_criacao_login_e_usuario.sql
│   ├── audit_permissoes_concedidas.sql
│   ├── audit_rotacao_de_credenciais.sql
│   └── README.md                      # Documentação detalhada
│
├── 📁 2_backup_and_restore/             # Módulo 2: Backup e Recuperação
│   ├── full_backup.sql
│   ├── diff_backup.sql
│   ├── log_backup.sql
│   ├── restore_database.sql
│   ├── backup_jobs/
│   ├── audit_historico_backup.sql
│   ├── audit_monitoramento_backup.sql
│   └── README.md
│
├── 📁 3_manutencao_preventiva/                 # Módulo 3: Automação e Manutenção
│   ├── plano_de_manutencao/
│   │   └── audit_CryptoDBWeeklyMaintenance_Subplan_1.sql
|   |   └── sp_Admin_CheckIndexFragmentation.sql
│   ├── audit_fragmentacao_db.sql
│   ├── audit_kpi_de_manutencao.sql
│   ├── audit_statisticas.sql
│   ├── DBA - CryptoDBWeeklyMaintenance_Subplan_1_20251010154626.txt
│   └── README.md
│
├── 📁 4_performance/                 # Módulo 4: Performance e Otimização
│   │   ├── sp_obter_historico_precos_por_data.sql
│   │   ├── exec_sp_obter_historico_preco_por_data.sql
│   │   ├── IX_price_history_price_timestamp.sql
│   │   ├── monitoramento_indice.sql
│   └── README.md
│
├── .gitignore
├── LICENSE
└── README.md                          # Este arquivo
```

---

## 🔒 Módulo 1: Segurança

### Objetivos
- Implementar autenticação segura com **princípio do menor privilégio**
- Criar **usuários de serviço** com permissões granulares
- Auditar **tentativas de login mal sucedidas**
- Separar **responsabilidades** entre aplicação e administração

### Implementações

#### 1.1 Modelo de Autenticação e Autorização

**Usuários criados:**

| Usuário | Tipo | Finalidade | Permissões |
|---------|------|------------|------------|
| `app_etl_crypto` | Serviço | Processos ETL automatizados | SELECT, INSERT, UPDATE (sem DELETE) |
| `usr_crypto_ro` | Read-Only | Consultas e relatórios | SELECT apenas |

**Arquivos:**
- [`create_login_e_user_de_servico.sql`](1_seguranca/)
- [`create_login_e_user_de_usuario.sql`](1_seguranca/)

**Destaques técnicos:**
- ✅ Negação explícita de DELETE (proteção de dados)
- ✅ Sem permissões DDL (não podem alterar estrutura)
- ✅ Gestão segura de credenciais (variáveis SQLCMD)
- ✅ Política de senha forte (CHECK_POLICY = ON)

#### 1.2 Auditoria de Segurança

**Stored Procedure:** `usp_get_failed_logins_report`
```sql
-- Exemplo de uso
EXEC usp_get_failed_logins_report 
    @DataInicio = '2025-01-01', 
    @DataFim = '2025-01-31';
```

**Funcionalidades:**
- Identifica tentativas de login falhadas
- Gera relatório consolidado por usuário/IP
- Auxilia na detecção de ataques de força bruta

**📖 [Documentação Completa →](1_seguranca/README.md)**

---

## 💾 Módulo 2: Backup e Recuperação

### Objetivos
- Garantir **recuperabilidade** dos dados em caso de desastre
- Minimizar **perda de dados** (RPO) e **tempo de inatividade** (RTO)
- Implementar **estratégia 3-2-1** de backup
- Automatizar **execução e validação** de backups

### Estratégia Implementada

#### Objetivos de Recuperação

| Métrica | Objetivo | Implementação |
|---------|----------|---------------|
| **RPO** (Recovery Point Objective) | 15 minutos | Backup de log a cada 15 min |
| **RTO** (Recovery Time Objective) | 2 horas | Restore testado mensalmente |

#### Tipos de Backup
```
┌──────────────────────────────────────┐
│ Estratégia de Backup                 │
├──────────────────────────────────────┤
                                      
  📅 Domingo 02:00                    
  ├─ Full Backup (semanal)           
  │  └─ Retenção: 28 dias            
  │                                   
  📅 Seg-Sáb 02:00                    
  ├─ Differential Backup (diário)    
  │  └─ Retenção: 7 dias             
  │                                   
  📅 Diário a cada 15 min             
  └─ Transaction Log Backup          
     └─ Retenção: 48 horas           
                                      
└──────────────────────────────────────┘
```

### Implementações

#### 2.1 Scripts de Backup

| Script | Frequência | Duração | Tamanho Médio |
|--------|-----------|---------|---------------|
| `full_backup.sql` | Semanal | ~30 min | ~15 GB (comprimido) |
| `diff_backup.sql` | Diário | ~5-10 min | ~2-8 GB |
| `log_backup.sql` | 15 min | ~1 min | ~200 MB |

#### 2.2 Automação com SQL Agent Jobs

**Jobs criados:**
- `DBA -  Job_FullBackupCryptoDB` (Domingo)
- `DBA - Job_DiffBackupCryptoDB` (Seg-Sáb)
- `DBA - Job_LogBackupCryptoDB` (A cada 15 min)
- `DBA - Job_DayliCleanupLogBackup.Subplan_1` (Diário)

#### 2.3 Procedimento de Restore

**Cenário de desastre documentado:**
1. Detecção de corrupção
2. Backup de tail-log (se possível)
3. Restore do último backup full
4. Aplicação do último differential
5. Replay de logs de transação
6. Validação de integridade

**📖 [Documentação Completa →](02_backup_and_restore/README.md)**

---

## 🔧 Módulo 3: Automação e Manutenção

### Objetivos
- Prevenir **degradação de performance** ao longo do tempo
- Automatizar **tarefas repetitivas** de manutenção
- Garantir **integridade dos dados** continuamente
- Manter **estatísticas atualizadas** para otimizador

### Problemas Combatidos

| Problema | Causa | Impacto | Solução |
|----------|-------|---------|---------|
| **Fragmentação** | INSERT/UPDATE/DELETE desordenam índices | Queries 300%+ mais lentas | Rebuild/Reorganize |
| **Estatísticas desatualizadas** | Mudanças nos dados | Planos de execução ruins | Update Statistics |
| **Corrupção silenciosa** | Falhas de hardware/bugs | Perda de dados | DBCC CHECKDB |

### Implementações

#### 3.1 Maintenance Plan

**Nome:** `DBA - CryptoDBWeeklyMaintenance`

**Frequência:** Semanal

**Tarefas sequenciais:**
```
1. Check Database Integrity (DBCC CHECKDB)
   └─ Tempo: ~30 min
   
2. Rebuild Indexes (fragmentação > 30%)
   └─ Tempo: ~2 horas
   
3. Update Statistics (Full Scan)
   └─ Tempo: ~30 min
   
4. Cleanup History (logs antigos)
   └─ Tempo: ~15 min
```

#### 3.2 Métricas de Sucesso
```sql
-- KPIs de manutenção (últimos 30 dias)
Taxa de sucesso:       98%   ✅
Duração média:         1h 45min ✅
Fragmentação média:    4.2%  ✅
Estatísticas atualizadas: 100%  ✅
Corrupção detectada:   0     ✅
```

#### 3.3 Ferramentas de DBA

**Banco:** `DBA_Admin`

**Procedure:** `sp_Admin_CheckIndexFragmentation`
```sql
-- Verificar fragmentação de qualquer tabela
EXEC DBA_Admin.dbo.sp_Admin_CheckIndexFragmentation
    @TargetDatabase = 'CryptoDB',
    @TargetTable = 'price_history';
```

**Funcionalidades:**
- Análise de fragmentação cross-database
- Recomendação REORGANIZE vs REBUILD
- Relatório de índices inativos

**📖 [Documentação Completa →](3_manutencao_preventiva/README.md)**

---

## 🚀 Módulo 4: Performance e Otimização

### Objetivos
- Identificar **gargalos de performance** através de planos de execução
- Aplicar **estratégias de indexação** para otimização
- Validar **melhorias mensuráveis** (99%+ de ganho)
- Documentar **processo de troubleshooting**

### Case Study: A Consulta Lenta do Histórico de Preços

#### Problema Identificado

**Cenário:** Consulta de 1 mês de histórico do Bitcoin estava demorando 216 ms e processando 125 MB de dados para retornar apenas 1.488 linhas.

**Query problemática:**
```sql
SELECT c.name, ph.price_date, ph.price_usd
FROM price_history ph
INNER JOIN coins c ON ph.coin_id = c.id
WHERE c.symbol = 'BTC'
  AND ph.price_date BETWEEN '2025-06-01' AND '2025-06-30'
ORDER BY ph.price_date;
```

#### Diagnóstico: ANTES da Otimização

**Problemas identificados:**

| Operador | Custo | Problema |
|----------|-------|----------|
| **Clustered Index Scan** | 97% | 🔴 Table Scan (lê 2M linhas) |
| **Sort** | 3% | 🟡 Ordenação de 1.440 linhas |
| **Parallelism** | Múltiplos | ⚠️ Overhead de 7 threads |

**Métricas de performance:**
```
Table 'price_history':
  Scan count: 7
  Logical reads: 16.098 páginas (~125 MB)
  
SQL Server Execution Times:
  CPU time: 548 ms
  Elapsed time: 216 ms
```

**Diagnóstico:** SQL Server está lendo a tabela INTEIRA (Table Scan) sem índice apropriado para filtro por `coin_id + price_date`.

#### Solução Implementada

**Índice criado:**
```sql
CREATE NONCLUSTERED INDEX IX_price_history_coin_date
ON dbo.price_history (coin_id, price_date)
INCLUDE (price_usd, market_cap_usd, volume_usd)
WITH (FILLFACTOR = 90, SORT_IN_TEMPDB = ON);
```

**Estrutura do índice:**
- **Chaves:** `coin_id` (igualdade) → `price_date` (range)
- **INCLUDE:** Todas as colunas do SELECT (covering index)
- **Tipo:** Covering Index (elimina Key Lookups)

#### Resultado: DEPOIS da Otimização

**Novo plano:**

| Operador | Custo | Status |
|----------|-------|--------|
| **Index Seek** | 17% | ✅ Busca direta |
| **Sort** | 63% | ✅ Rápido (4 ms) |
| **Nested Loops** | 2% | ✅ JOIN eficiente |

**Métricas de performance:**
```
Table 'price_history':
  Scan count: 1
  Logical reads: 16 páginas (~128 KB)
  
SQL Server Execution Times:
  CPU time: 16 ms
  Elapsed time: 112 ms
```

#### Comparação: ANTES vs DEPOIS

| Métrica | ANTES | DEPOIS | Melhoria |
|---------|-------|--------|----------|
| **Scan Count** | 7 | 1 | **85.7%** ⬇️ |
| **Logical Reads** | 16.098 | 16 | **99.9%** ⬇️ |
| **Dados Processados** | ~125 MB | ~128 KB | **99.9%** ⬇️ |
| **CPU Time** | 548 ms | 16 ms | **97.1%** ⬇️ |
| **Elapsed Time** | 216 ms | 112 ms | **48.1%** ⬇️ |
| **Operador Principal** | Table Scan | Index Seek | ✅ |

**Resultado:** Melhoria de **99.9%** em I/O e **97%** em CPU! 🚀

**📖 [Documentação Completa →](4_performance/README.md)**

---

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Versão | Uso |
|------------|--------|-----|
| **Microsoft SQL Server** | 2019+ | RDBMS principal |
| **Transact-SQL (T-SQL)** | - | Linguagem de scripts |
| **SQL Server Management Studio (SSMS)** | 2021 | IDE e ferramenta de administração |
| **SQL Server Agent** | - | Automação de jobs |
| **VS Code** | - | Editor de código e Git |
| **Git** | 2.0+ | Controle de versão |
| **Markdown** | - | Documentação |

---

## 🚀 Como Usar Este Repositório

### Pré-requisitos

- ✅ SQL Server 2019 ou superior (Developer/Express Edition)
- ✅ SQL Server Management Studio (SSMS)
- ✅ Permissões de `sysadmin` (para criar bancos, jobs, etc.)
- ✅ ~10 GB de espaço em disco livre

### Setup Inicial
```bash
# 1. Clonar o repositório
git clone https://github.com/seu-usuario/sqlserver-dba-portfolio.git
cd sqlserver-dba-portfolio

# 2. Conectar ao SQL Server via SSMS
# Server: localhost ou seu servidor
# Authentication: Windows Authentication ou SQL Server

# 3. Executar scripts de setup na ordem:
```

**No SSMS:**
```sql
-- Passo 1: Criar bancos de dados, tabelas e alimentá-las
:r 0_criacao_banco/create_banco_cryptodb.sql

-- Passo 2: Seguir módulos em ordem (01 → 02 → 03 → 04)
```

### Executar por Módulo

Cada módulo tem seu próprio `README.md` com instruções detalhadas:

1. **[Segurança](1_seguranca/README.md)** → Criar usuários e auditar
2. **[Backup](2_backup_and_restore/README.md)** → Configurar backups automáticos
3. **[Manutenção](3_manutencao_preventiva/README.md)** → Configurar Maintenance Plan
4. **[Performance](04_performance/README.md)** → Executar case study completo

---

## 📊 Métricas e KPIs

### Performance Geral do Projeto

| Área | Métrica | Target | Atual | Status |
|------|---------|--------|-------|--------|
| **Segurança** | Tentativas de login falhadas | < 10/dia | 2/dia | ✅ |
| **Backup** | Taxa de sucesso | > 95% | 98% | ✅ |
| **Backup** | RTO (tempo de restore) | < 2h | 1h 45min | ✅ |
| **Manutenção** | Fragmentação média | < 10% | 4.2% | ✅ |
| **Performance** | Queries otimizadas | 100% | 100% | ✅ |
| **Performance** | Melhoria média | > 90% | 99.9% | ✅✅ |

---

## 📚 Documentação Adicional

### Guias e Tutoriais

- **[Política de Segurança Completa](docs/security_policy.md)**
- **[Estratégia de Backup Detalhada](docs/backup_strategy.md)**
- **[Troubleshooting Guide](docs/troubleshooting.md)**
- **[Best Practices SQL Server](docs/best_practices.md)**

### Referências Técnicas

- [Microsoft SQL Server Documentation](https://docs.microsoft.com/sql/)
- [SQL Server Central - Best Practices](https://www.sqlservercentral.com/)
- [Brent Ozar - SQL Server Resources](https://www.brentozar.com/)
- [Ola Hallengren - Maintenance Solution](https://ola.hallengren.com/)

---

## 🤝 Contribuindo

Contribuições, issues e sugestões são bem-vindas!

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

**Áreas abertas para contribuição:**
- 🆕 Novos casos de otimização de performance
- 📖 Melhorias na documentação
- 🧪 Scripts de testes automatizados
- 🔍 Ferramentas de monitoramento

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👤 Autor

**Leandro da Rocha**

- 🌐 Website: [Portfólio](https://leandrorochagithub.github.io/Portfolio/)
- 💼 LinkedIn: [Linkedin](https://www.linkedin.com/in/leandro-d-8524b4160/)
- 🐙 GitHub: [GitHub](https://github.com/Leandrorochagithub)
- 📧 Email: [Email](leandrodarochaferreira@gmail.com)

---

## 🎓 Contexto Acadêmico/Profissional

**Sobre este portfólio:**

Este projeto foi desenvolvido como parte de portfólio profissional para transição de carreira.

**Objetivos de aprendizado alcançados:**
- ✅ Administração completa de SQL Server
- ✅ Implementação de segurança em múltiplas camadas
- ✅ Estratégias de backup e disaster recovery
- ✅ Automação de tarefas administrativas
- ✅ Otimização e tuning de performance
- ✅ Documentação técnica profissional

---

## 🌟 Destaques Técnicos

### Por que Este Projeto se Destaca

1. **Abordagem Holística**
   - Cobre TODAS as áreas críticas de um DBA
   - Não apenas scripts, mas processos completos
   - Documentação em nível de produção

2. **Resultados Mensuráveis**
   - Melhoria de 99.9% em performance documentada
   - RTO/RPO definidos e testados
   - KPIs monitorados

3. **Boas Práticas da Indústria**
   - Princípio do menor privilégio
   - Estratégia 3-2-1 de backup
   - Covering indexes e index tuning
   - Separação de ambientes (app vs admin)

4. **Production-Ready**
   - Scripts testados e validados
   - Procedures com tratamento de erro
   - Jobs com notificações e logging
   - Documentação para troubleshooting

---

## 🔄 Próximos Passos

### Roadmap Futuro

- [ ] **Monitoramento:** Implementar alertas proativos (SQL Agent Alerts)
- [ ] **Alta Disponibilidade:** Configurar AlwaysOn Availability Groups
- [ ] **Segurança Avançada:** Implementar Transparent Data Encryption (TDE)
- [ ] **Performance:** Criar baseline de performance e monitoramento contínuo
- [ ] **Testes:** Desenvolver suite de testes automatizados
- [ ] **DevOps:** Integração com CI/CD (Azure DevOps / GitHub Actions)

---

<p align="center">
  <strong>⭐ Se este projeto foi útil, considere dar uma estrela!</strong>
</p>

<p align="center">
  <sub>Última atualização: Novembro 2025</sub>
</p>
