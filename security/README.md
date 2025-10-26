# 🔒 Segurança: Modelo de Autenticação e Autorização

## 📖 Visão Geral

Implementação de um modelo de segurança robusto baseado no **princípio do menor privilégio** (Principle of Least Privilege - PoLP), garantindo que cada usuário/aplicação tenha apenas as permissões essenciais para executar suas funções.

### Princípios de Segurança Aplicados

| Princípio | Implementação |
|-----------|---------------|
| **Menor Privilégio** | Usuários recebem apenas permissões mínimas necessárias |
| **Separação de Responsabilidades** | Usuários específicos para cada função (ETL, leitura) |
| **Defesa em Profundidade** | Múltiplas camadas: Login → Usuário → Permissões → Auditoria |
| **Negação Explícita** | DENY para operações perigosas (DELETE) |
| **Auditoria Contínua** | Monitoramento de tentativas de acesso |

---

## 👥 Conceitos: Login vs Usuário

### 🔑 Login (Nível de Instância)

- **Escopo:** SQL Server (instância inteira)
- **Função:** Autenticação - permite conexão ao servidor
- **Localização:** `master.sys.server_principals`
- **Analogia:** "Cartão de acesso ao prédio"

### 👤 Usuário (Nível de Banco)

- **Escopo:** Banco de dados específico
- **Função:** Autorização - define o que pode ser acessado
- **Localização:** `[database].sys.database_principals`
- **Analogia:** "Chave para sala específica no prédio"

**Fluxo de Autenticação:**
```
Conexão → Autenticação (Login) → Autorização (Usuário) → Permissões (Objetos)
```

---

## 🛠️ Implementação

### 1. Criação de Logins e Usuários

**Objetivo:** Criar contas de serviço com permissões granulares para aplicações e usuários.

#### 1.1. Usuário de Serviço: ETL (Leitura/Escrita)

**Arquivo:** `create_serv_user.sql`

**Nome:** `app_etl_crypto`

**Finalidade:** Executar processos de ETL (Extract, Transform, Load) automatizados

**Permissões:**
- ✅ `SELECT` - Leitura de dados existentes
- ✅ `INSERT` - Inserção de novos registros
- ✅ `UPDATE` - Atualização de registros existentes
- ❌ `DELETE` - **NEGADO** explicitamente (proteção contra deleções acidentais)
- ❌ `DDL` - **SEM PERMISSÃO** para alterar estrutura do banco

**Tabelas com acesso:**
- `dbo.coins` - Cadastro de criptomoedas
- `dbo.price_history` - Histórico de preços


#### 1.2. Usuário: Somente Leitura (Read-Only)

**Arquivo:** `create_usr_user.sql`

**Nome:** `usr_crypto_ro`

**Finalidade:** Acesso de leitura para relatórios, dashboards e consultas analíticas

**Permissões:**
- ✅ `SELECT` - Apenas leitura
- ❌ `INSERT/UPDATE/DELETE` - **NEGADO** implicitamente (não concedido)
---

### 📊 Matriz de Permissões

| Usuário | SELECT | INSERT | UPDATE | DELETE | DDL | Tabelas |
|---------|--------|--------|--------|--------|-----|---------|
| `app_etl_crypto` | ✅ | ✅ | ✅ | ❌ (DENY) | ❌ | coins, price_history |
| `usr_crypto_ro` | ✅ | ❌ | ❌ | ❌ | ❌ | coins, price_history |
| `dbo` (owner) | ✅ | ✅ | ✅ | ✅ | ✅ | Todas |

---

### 🔍 Validação e Testes

#### Verificar Criação de Logins e Usuários no Banco

**Arquivo:** `audit-instance_database_login.sql`

<img width="1800" height="500" alt="Captura de tela 2025-10-26 111106" src="https://github.com/user-attachments/assets/329a854f-0d35-42ef-95bb-bea673de61fc" />

#### Auditar Permissões Concedidas

**Arquivo:** `audit-database_permissions.sql`

**Resultado esperado:**

<img width="1800" height="500" alt="Captura de tela 2025-10-26 110805" src="https://github.com/user-attachments/assets/f3695f8a-39b2-4159-9afa-527e1e45f640" />


#### Testar Permissões

**Arquivo:** `permission_test.sql`

<img width="1800" height="500" alt="Captura de tela 2025-10-26 134805" src="https://github.com/user-attachments/assets/0f920a3f-b73c-4020-baad-dd6595b328b5" />

---

### 🔐 Boas Práticas de Segurança

#### 1. **Gestão de Senhas** 🚨 CRÍTICO

**❌ NÃO FAZER:**
```sql
-- NUNCA hardcode senhas no script!
CREATE LOGIN app_etl WITH PASSWORD = 'P@ssw0rd123';
```

**✅ FAZER:**

**Opção A: Usar Variáveis SQLCMD**
```bash
# Executar via linha de comando
sqlcmd -S servidor -d master -i create_login.sql -v ETL_PASSWORD="SenhaSegura123!"
```

**Opção B: Azure Key Vault (Ambiente Cloud)**
```sql
-- Referência ao Key Vault
CREATE LOGIN app_etl 
WITH PASSWORD = N'$(KeyVault.ETL_Password)';
```

**Opção C: Prompt Interativo**
```powershell
# Script PowerShell
$password = Read-Host "Digite a senha para app_etl" -AsSecureString
$plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
)
Invoke-Sqlcmd -Query "CREATE LOGIN app_etl WITH PASSWORD = '$plainPassword'"
```

**Opção D: Autenticação Integrada do Windows (Mais Seguro)**
```sql
-- Usar conta de serviço do Windows/AD
CREATE LOGIN [DOMAIN\svc_etl_crypto] FROM WINDOWS;
```

#### 2. **Política de Senhas**
```sql
-- Aplicar política de senha do Windows
CREATE LOGIN app_etl 
WITH PASSWORD = N'$(PASSWORD)',
     CHECK_POLICY = ON,        -- Força complexidade de senha
     CHECK_EXPIRATION = ON,    -- Força expiração periódica
     DEFAULT_DATABASE = CryptoDB;
```

**Recomendações:**
- Mínimo 12 caracteres
- Letras maiúsculas e minúsculas
- Números e caracteres especiais
- Expiração a cada 90 dias
- Histórico de 12 senhas anteriores

#### 3. **Rotação de Credenciais**

**Arquivo:** `audit_last_pwd_change.sql`

<img width="1800" height="600" alt="Captura de tela 2025-10-26 135532" src="https://github.com/user-attachments/assets/20172d93-388a-4d60-b1e9-006cfe4a1942" />

#### 4. **Auditoria de Acessos**

**Arquivo:** `usp_get_failed_logins_report.sql`

<img width="1800" height="600" alt="audit_result" src="https://github.com/user-attachments/assets/154f1a00-e945-4b37-afe2-bb4854481614" />

#### 5. **Princípio do Menor Privilégio - Checklist**

- [ ] Usuário tem apenas permissões essenciais?
- [ ] DELETE está explicitamente negado onde não é necessário?
- [ ] Usuário não tem permissões de administrador (sysadmin)?
- [ ] Usuário não tem permissões de DDL (ALTER, CREATE, DROP)?
- [ ] Senha segue política de complexidade?
- [ ] Credenciais não estão hardcoded em código?
- [ ] Auditoria de login está ativada?

---

### 📋 Troubleshooting

#### Problema: Login não consegue conectar

**Erro:** `Login failed for user 'app_etl_crypto'`

**Diagnóstico:**
```sql
-- Verificar se login existe e está ativo
SELECT name, is_disabled 
FROM sys.sql_logins 
WHERE name = 'app_etl_crypto';

-- Verificar tentativas de login
SELECT TOP 10 *
FROM sys.dm_exec_sessions
WHERE login_name = 'app_etl_crypto'
ORDER BY login_time DESC;
```

**Soluções:**
1. Verificar se senha está correta
2. Verificar se login não está desabilitado: `ALTER LOGIN app_etl_crypto ENABLE;`
3. Verificar política de firewall/rede

#### Problema: Usuário não tem acesso ao banco

**Erro:** `The server principal "app_etl_crypto" is not able to access the database "CryptoDB"`

**Solução:**
```sql
USE CryptoDB;
CREATE USER app_etl_crypto FOR LOGIN app_etl_crypto;
```

#### Problema: Permissão negada

**Erro:** `The SELECT permission was denied on the object 'coins'`

**Diagnóstico:**
```sql
-- Ver permissões atuais
EXEC sp_helprotect @username = 'app_etl_crypto';
```

**Solução:**
```sql
GRANT SELECT ON dbo.coins TO app_etl_crypto;
```

---

### 📚 Referências

- [SQL Server Security Best Practices](https://docs.microsoft.com/sql/relational-databases/security/)
- [Principle of Least Privilege](https://docs.microsoft.com/sql/relational-databases/security/authentication-access/getting-started-with-database-engine-permissions)
- [CREATE LOGIN - Microsoft Docs](https://docs.microsoft.com/sql/t-sql/statements/create-login-transact-sql)
- [GRANT Permissions - Microsoft Docs](https://docs.microsoft.com/sql/t-sql/statements/grant-transact-sql)
