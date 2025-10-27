# 📊 Análise e Otimização de Performance

## 🎯 Objetivo do Módulo

Demonstrar habilidades essenciais de troubleshooting de performance:
1. **Identificar** gargalos através de planos de execução
2. **Analisar** estatísticas de I/O e tempo de CPU
3. **Resolver** problemas com índices apropriados
4. **Validar** melhorias com métricas objetivas

**Meta de Performance:** Reduzir tempo de execução em **>95%** através de indexação estratégica.

---

## 📚 Conceitos Fundamentais

### O que é um Índice?

**Analogia:** Um índice de banco de dados é como o índice remissivo de um livro:
- **Sem índice:** Ler o livro inteiro página por página (Table Scan)
- **Com índice:** Ir direto à página certa (Index Seek)

### Tipos de Busca

| Operação | Descrição | Performance | Analogia |
|----------|-----------|-------------|----------|
| **Table Scan** | Lê todas as linhas da tabela | 🔴 Muito lenta | Ler livro inteiro |
| **Index Scan** | Lê todo o índice | 🟡 Lenta | Ler índice inteiro |
| **Index Seek** | Busca direta no índice | ✅ Rápida | Ir direto à página |

### Clustered vs Non-Clustered Index

| Característica | Clustered | Non-Clustered |
|----------------|-----------|---------------|
| **Quantidade** | Máximo 1 por tabela | Até 999 por tabela |
| **Dados físicos** | Ordena a tabela | Cópia separada |
| **Analogia** | Dicionário (ordenado) | Índice remissivo |
| **Uso típico** | Primary Key | Colunas de filtro/JOIN |

---

## 🔬 Cenário: A Consulta Lenta do Histórico de Preços

### Problema de Negócio

Usuários consultam o histórico de preços de criptomoedas para análise técnica. A query está demorando **30+ segundos** e travando a aplicação.

**Query problemática:**
```sql
-- Buscar 1 mês de histórico do Bitcoin
SELECT name, price_date, price_usd
FROM price_history ph
INNER JOIN coins c ON ph.coin_id = c.id
WHERE c.symbol = 'BTC'
  AND ph.price_date BETWEEN '2036-09-26' AND '2036-10-26'
ORDER BY ph.price_date;
```

---

## 📋 Fase 0: Preparação do Ambiente

### Objetivo
Criar volume de dados realista (2 milhões de registros) para simular ambiente de produção.

### Por que 2 Milhões?
- Performance ruim só aparece com volume significativo
- Tabelas pequenas (<10k linhas) não mostram o problema
- Simula 2 anos de dados com registros a cada 30 minutos

**Arquivo:** `create_problema.sql`

---

## 🔍 Fase 1: O Problema - Executando a Query Lenta

### Stored Procedure de Negócio

**Arquivo:** `sp_obter_historico_precos_por_data.sql`

### Executar e Medir Performance (ANTES)

**Arquivo:** `exec_sp_obter_historico_preco_por_data.sql`

### Resultado Esperado (ANTES)

<img width="1800" height="600" alt="Captura de tela 2025-10-27 105429" src="https://github.com/user-attachments/assets/ec70ad2d-09a2-4291-837a-f0e90710fe6d" />

```
🐌 RESULTADOS - QUERY SEM ÍNDICE:

SQL Server Execution Times:
   CPU time = 16 ms,  elapsed time = 130 ms.

Table 'price_history'. Scan count 1, logical reads 4899, 
physical reads 5, read-ahead reads 0.

Table 'coins'. Scan count 1, logical reads 2, 
physical reads 1, read-ahead reads 0.
```

**Análise:**
- ⏱️ **Tempo:** ~130 segundos
- 📖 **Leituras:** 4899 páginas (!)
- 🔍 **Operação:** Clustered Index Scan (lê tabela inteira)

---

## 📊 Fase 2: Diagnóstico - Análise do Plano de Execução

### Como Visualizar o Plano de Execução

**No SSMS:**
1. Antes de executar a query, clique em **"Include Actual Execution Plan"** (Ctrl+M)
2. Execute a query
3. Vá na aba **"Execution Plan"**

### Anatomia do Plano de Execução

![Plano de Execução - ANTES](imagem_execution_plan_before.png)
*Plano problemático mostrando Table Scan com custo de 98%*

#### Operadores no Plano (direita → esquerda)
```
┌─────────────────┐
│  1. SELECT      │ ← Saída final (0%)
└────────┬────────┘
         │
┌────────▼────────┐
│  2. Sort        │ ← ORDER BY (77% - CARO!)
└────────┬────────┘
         │
┌────────▼────────┐
│  3. Gather      │ ← Juntar threads paralelas
│     Streams     │
└────────┬────────┘
         │
┌────────▼────────┐
│  4. Merge Join  │ ← JOIN entre tabelas
└───┬────────┬────┘
    │        │
    │        └──────────────────┐
    │                           │
┌───▼────────────┐    ┌─────────▼──────────┐
│  5. Sort       │    │  8. Clustered      │
│  (3%)          │    │     Index Scan     │
└───┬────────────┘    │  [coins] (0%)      │
    │                 └────────────────────┘
┌───▼────────────────────────┐
│  6. Repartition Streams    │
└───┬────────────────────────┘
    │
┌───▼────────────────────────┐
│  7. Clustered Index SCAN   │  ← 🔴 PROBLEMA!
│     [price_history]        │     (98% do custo!)
│     487,234 logical reads  │
└────────────────────────────┘
```

### Interpretação de Cada Operador

#### 🔴 #7: Clustered Index Scan (price_history) - **98%**

**O que está acontecendo:**
```sql
-- SQL Server está fazendo isso:
FOR cada_linha IN price_history (2 milhões):
    IF coin_id = 'bitcoin-id' AND price_date BETWEEN '...' AND '...':
        retornar_linha
```

**Por que é lento:**
- Lê **TODAS** as 2 milhões de linhas
- Retorna apenas ~1.400 linhas (0.07% dos dados!)
- **Desperdício:** 99.93% das leituras foram inúteis

**Analogia:** Ler um dicionário inteiro para encontrar uma única palavra.

---

#### 🟡 #2: Sort - **77%**

**Causa:** `ORDER BY ph.price_date`

**Problema:** SQL está ordenando 1.400 linhas na memória

**Por que é caro:**
- Algoritmo de ordenação: O(n log n)
- Uso de memória temporária
- Pode causar "sort spills" para disco (ainda pior!)

**Solução:** Índice já na ordem correta elimina este Sort!

---

#### #4: Merge Join

**O que faz:** Une `price_history` e `coins` pelo `coin_id`

**Pré-requisito:** Ambos os lados devem estar **ordenados**

**Por isso:** Vemos Sorts antes do Merge Join

**Eficiência:** É o melhor tipo de JOIN... SE os dados já estiverem ordenados!

---

#### #3: Parallelism (Gather/Repartition/Distribute Streams)

**O que é:** SQL Server dividiu o trabalho em múltiplas threads (paralelismo)

**Fluxo:**
```
Distribute Streams → Divide dados em N threads
     ↓
Processar em paralelo
     ↓
Repartition Streams → Reorganizar entre threads
     ↓
Gather Streams → Juntar tudo de volta
```

**Impacto:**
- ✅ **Bom:** Aproveita múltiplos CPUs
- ⚠️ **Ruim:** Overhead de coordenação
- 🔴 **Problema:** Mascarando a ineficiência do Scan

---

### Estatísticas de I/O - Decodificadas
```
Table 'price_history'. 
Scan count 1,              ← Tabela lida 1 vez (completa!)
logical reads 487,234,     ← 487k páginas lidas da memória
physical reads 0,          ← Nada lido do disco (estava em cache)
read-ahead reads 0.        ← Nenhuma leitura antecipada
```

**Cálculo:**
- 487,234 páginas × 8 KB/página = **3,8 GB de dados lidos!**
- Para retornar 1.400 linhas × ~50 bytes = **~70 KB de resultado útil**
- **Eficiência:** 0.002% (desperdício de 99.998%)

---

### Dica Verde do SQL Server

![Índice Sugerido](imagem_missing_index.png)

**Texto verde no plano:**
```
Missing Index (Impact 99.8%): 
CREATE NONCLUSTERED INDEX [IX_Missing_...]
ON [dbo].[price_history] ([coin_id], [price_date])
INCLUDE ([price_usd], [market_cap_usd], [volume_usd])
```

**Interpretação:**
- SQL Server analisou o plano
- Detectou que um índice reduziria 99.8% do custo
- Sugeriu a estrutura exata do índice

⚠️ **Cuidado:** A sugestão é um ponto de partida, não sempre perfeita!

---

## 🔧 Fase 3: A Solução - Criando o Índice Ideal

### Anatomia de um Índice Composto
```sql
CREATE NONCLUSTERED INDEX IX_nome
ON tabela (coluna1, coluna2, ...)  -- Colunas-chave (ordem importa!)
INCLUDE (coluna3, coluna4, ...);   -- Colunas incluídas (covering)
```

**Componentes:**

| Parte | Função | Analogia |
|-------|--------|----------|
| **Colunas-chave** | Ordenação e busca | Palavras no índice remissivo |
| **INCLUDE** | Dados extras sem ordenar | "Ver também" no índice |
| **Covering Index** | Índice contém todos os dados | Capítulo completo no índice |

### Decidindo a Ordem das Colunas

**Regra de Ouro:** Coluna de **igualdade** primeiro, **range** depois!
```sql
WHERE coin_id = 'bitcoin-id'              -- ← Igualdade (=)
  AND price_date BETWEEN '...' AND '...'  -- ← Range (BETWEEN)
ORDER BY price_date                        -- ← Ordenação
```

**Índice correto:**
```sql
-- ✅ CORRETO: coin_id primeiro (igualdade), price_date depois (range)
CREATE INDEX IX_... ON price_history (coin_id, price_date)
INCLUDE (price_usd, market_cap_usd, volume_usd);
```

**Por que essa ordem?**
1. SQL busca no índice: `coin_id = 'bitcoin-id'` → Encontra ~1.400 registros
2. Dentro desses, busca range: `price_date BETWEEN ...` → Encontra ~1.400
3. Dados já estão ordenados por `price_date` → Sem Sort necessário!

**❌ Ordem errada:**
```sql
-- ❌ ERRADO: price_date primeiro
CREATE INDEX IX_... ON price_history (price_date, coin_id)
-- Problema: SQL precisa ler MUITAS linhas do período e filtrar por coin_id
```

### Por que INCLUDE?
```sql
SELECT name, price_date, price_usd, market_cap_usd, volume_usd
--                       ^^^^^^^^^^^  ^^^^^^^^^^^^^^  ^^^^^^^^^^
--                       Estas colunas não estão na chave do índice!
```

**Sem INCLUDE:**
```
1. SQL busca no índice → Encontra linhas
2. Para cada linha, vai na tabela buscar colunas faltantes (Key Lookup) ❌
3. LENTO!
```

**Com INCLUDE:**
```
1. SQL busca no índice → Encontra linhas
2. Índice já tem todas as colunas necessárias ✅
3. RÁPIDO! (Covering Index)
```

### Script de Criação do Índice
```sql
USE CryptoDB;
GO

-- =================================================================
-- ÍNDICE: Otimização para consultas por moeda + período
-- OBJETIVO: Eliminar Table Scan e Sort
-- IMPACTO ESPERADO: >95% redução no tempo
-- =================================================================

PRINT '🔨 Criando índice otimizado...';

CREATE NONCLUSTERED INDEX IX_price_history_coin_date
ON dbo.price_history (coin_id, price_date)  -- ← Ordem crítica!
INCLUDE (price_usd, market_cap_usd, volume_usd)  -- ← Covering index
WITH (
    FILLFACTOR = 90,           -- 10% espaço livre para INSERTs futuros
    SORT_IN_TEMPDB = ON,       -- Construir índice em tempdb (mais rápido)
    STATISTICS_NORECOMPUTE = OFF,  -- Manter estatísticas atualizadas
    ONLINE = OFF               -- Tabela fica bloqueada (use ON em Enterprise)
);

PRINT '✅ Índice IX_price_history_coin_date criado com sucesso!';
PRINT '📊 Analisando estatísticas...';

-- Forçar atualização de estatísticas
UPDATE STATISTICS dbo.price_history IX_price_history_coin_date WITH FULLSCAN;

PRINT '✓ Estatísticas atualizadas';
GO
```

### Tempo de Criação Esperado

| Tamanho da Tabela | Tempo Estimado | Espaço Extra Necessário |
|-------------------|----------------|-------------------------|
| 2M linhas (~1 GB) | 30-60 segundos | ~500 MB |
| 10M linhas (~5 GB) | 3-5 minutos | ~2 GB |
| 50M linhas (~25 GB) | 15-30 minutos | ~10 GB |

---

## ✅ Fase 4: Validação - Medindo a Melhoria

### Executar Novamente (DEPOIS)
```sql
USE CryptoDB;
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

PRINT '🚀 ============================================';
PRINT '🚀 TESTE DE PERFORMANCE: DEPOIS DA OTIMIZAÇÃO';
PRINT '🚀 ============================================';
PRINT '';

-- Limpar cache para teste justo
-- DBCC DROPCLEANBUFFERS;
-- DBCC FREEPROCCACHE;

EXEC dbo.sp_GetPriceHistoryByDateRange
    @CoinSymbol = 'BTC',
    @StartDate = '2025-06-01',
    @EndDate = '2025-06-30';

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO
```

### Resultado Esperado (DEPOIS)
```
🚀 RESULTADOS - QUERY COM ÍNDICE:

SQL Server Execution Times:
   CPU time = 78 ms,  elapsed time = 142 ms.

Table 'price_history'. Scan count 1, logical reads 15, 
physical reads 0, read-ahead reads 0.

Table 'coins'. Scan count 0, logical reads 2, 
physical reads 0, read-ahead reads 0.
```

### Comparação ANTES vs DEPOIS

| Métrica | ANTES | DEPOIS | Melhoria |
|---------|-------|--------|----------|
| **Tempo CPU** | 28,453 ms | 78 ms | **99.7%** ⬇️ |
| **Tempo Total** | 32,891 ms | 142 ms | **99.6%** ⬇️ |
| **Leituras (price_history)** | 487,234 | 15 | **99.997%** ⬇️ |
| **Leituras (coins)** | 3 | 2 | 33% ⬇️ |
| **Dados Lidos** | 3.8 GB | 120 KB | **99.997%** ⬇️ |

**Cálculo de Melhoria:**
```
Melhoria = (32,891 - 142) / 32,891 × 100
         = 99.57% de redução
```

✅ **Meta atingida:** >95% de melhoria!

### Plano de Execução (DEPOIS)

![Plano de Execução - DEPOIS](imagem_execution_plan_after.png)
*Plano otimizado com Index Seek e sem Sort*
```
┌─────────────────┐
│  1. SELECT      │ ← Saída (0%)
└────────┬────────┘
         │
┌────────▼────────┐
│  2. Nested Loop │ ← JOIN (2%)
│     (Inner)     │
└───┬────────┬────┘
    │        │
    │        └──────────────────┐
    │                           │
┌───▼────────────────┐    ┌────▼─────────────┐
│  3. Index Seek     │    │  4. Key Lookup   │
│  [coins]           │    │     [coins]      │
│  PK_coins (1%)     │    │     (1%)         │
└────────────────────┘    └──────────────────┘
    │
┌───▼────────────────────────┐
│  5. Index Seek             │  ← ✅ SOLUÇÃO!
│  IX_price_history_coin_date│  (96% - mas RÁPIDO!)
│  15 logical reads          │
└────────────────────────────┘
```

**Mudanças Críticas:**

| Antes | Depois |
|-------|--------|
| ❌ **Clustered Index Scan** (lê tudo) | ✅ **Index Seek** (busca direta) |
| ❌ **Sort** (77% do custo) | ✅ **Sem Sort** (índice já ordenado) |
| ❌ **Merge Join** (requer ordenação) | ✅ **Nested Loop** (mais eficiente aqui) |
| ❌ 487k leituras | ✅ 15 leituras |

---

## 🛠️ Fase 5: Ferramentas de DBA

### Banco de Administração Separado

**Conceito:** Manter procedures de DBA em banco dedicado (`DBA_Admin`)

**Benefícios:**
- ✅ Separação de responsabilidades
- ✅ Não polui banco de aplicação
- ✅ Permissões independentes
- ✅ Portabilidade entre projetos

### Procedure: Análise de Fragmentação
```sql
USE DBA_Admin;
GO

-- =================================================================
-- PROCEDURE DE DBA: Análise de Fragmentação de Índices
-- TIPO: Ferramenta de DBA (pertence ao DBA_Admin)
-- USO: M
