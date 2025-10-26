### 1. Criação de Login e Usuário

**Arquivo:** `create_login_user_script.sql`

**Objetivo:** Implementar autenticação segura seguindo o princípio do menor privilégio.

**O que faz:**
- Cria login no nível de instância SQL Server
- Cria usuário no nível de banco de dados
- Aplica permissões mínimas necessárias

**Como executar:**
1. Conecte-se ao SQL Server como administrador
2. Execute o script: `create_login_user_script.sql`
3. Verifique a criação: `SELECT * FROM sys.server_principals WHERE name = 'nome_login'`

<img width="1800" height="200" alt="loginuser" src="https://github.com/user-attachments/assets/da08300b-8e55-4e9d-baf0-18195ba9b3b0" />

### 2. Auditoria de Tentativas de Login

**Arquivo:** `usp_get_failed_logins_report.sql`

**Objetivo:** Monitorar e reportar tentativas mal sucedidas de autenticação.

**Funcionalidades:**
- Identifica tentativas de login falhadas
- Gera relatório consolidado
- Auxilia na detecção de ataques

**Parâmetros:**
- `@DataInicio`: Data inicial do período (opcional)
- `@DataFim`: Data final do período (opcional)

**Exemplo de uso:**
```sql
-- Últimas 24 horas
EXEC usp_get_failed_logins_report

-- Período específico
EXEC usp_get_failed_logins_report 
    @DataInicio = '2025-01-01', 
    @DataFim = '2025-01-31'
```

**Resultado esperado:**
<img width="1800" height="200" alt="audit_result" src="https://github.com/user-attachments/assets/154f1a00-e945-4b37-afe2-bb4854481614" />

