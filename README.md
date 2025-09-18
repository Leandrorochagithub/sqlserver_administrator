# Portfólio de Administração de Banco de Dados SQL Server

Este repositório contém uma coleção de scripts e análises que demonstram as competências essenciais de um Administrador de Banco de Dados (DBA). O objetivo é aplicar os princípios de segurança, backup, manutenção e otimização de performance em um banco de dados de projeto.
Estrutura do Projeto. O processo vai da extração dos dados de uma api pública, criação do Banco de Dados, sua alimentação, criação de Dashboard de Cryptos e Criação de Dasboard de manutenção do Banco de Dados. 

* Engenharia de Dados
* Adminstração de Bando de Dados Sql Server
* Análise de Dados

# ETAPA 01: ETL - Processo de carga de dados da API Coingecko

**1. config.py: Configurações de ambiente e conexões:**

<img width="982" height="783" alt="config_p1" src="https://github.com/user-attachments/assets/a3d900f7-5b2e-4d09-b21e-4f23f877dcad" />
<img width="973" height="308" alt="config_p2" src="https://github.com/user-attachments/assets/46047b3f-0fd3-4f43-8e2f-a8678f663af3" />


**2. schema.sql: Script de construção de tabelas no Banco de Dados:**

<img width="977" height="725" alt="schema" src="https://github.com/user-attachments/assets/2e88a41a-6316-4e7b-b248-9a89b26de8b3" />


**3. build_etl.py: Construtor do Bando de Dados:** 

<img width="983" height="631" alt="biuld_p1" src="https://github.com/user-attachments/assets/1ae5a00b-2620-400f-baaa-4fb7e0fa7e60" />
<img width="980" height="737" alt="biuld_p2" src="https://github.com/user-attachments/assets/912bf9c6-11f6-4020-8e18-16ba3b70ee36" />
<img width="968" height="307" alt="biuld_p3" src="https://github.com/user-attachments/assets/56441286-6b76-4568-8c8f-c380f3d0bf45" />


**4. teste_connection.py: Teste de conexão com o Banco de Dados:**

<img width="683" height="837" alt="teste_conexao_banco" src="https://github.com/user-attachments/assets/571b35b9-7ea7-4f8b-927b-71b94c6a0f02" />


**5. main_etl: Processo de execução etl dos dados:**

<img width="1187" height="750" alt="main_p1" src="https://github.com/user-attachments/assets/ed88d008-971a-4d86-9745-0c9e6a6b6cf9" />
<img width="1177" height="527" alt="main_p2" src="https://github.com/user-attachments/assets/ff417917-8b45-4e8b-b5e7-480161b9e960" />
<img width="1176" height="757" alt="main_p3" src="https://github.com/user-attachments/assets/10518f2c-7ba6-4a34-822d-d85ed5552db4" />
<img width="1183" height="708" alt="main_p4" src="https://github.com/user-attachments/assets/acb299aa-8f4c-426f-a4a3-0a3622c32caa" />
<img width="1186" height="761" alt="main_p5" src="https://github.com/user-attachments/assets/c06874df-2fc1-496e-aa91-f0b37938166b" />
<img width="1183" height="737" alt="main_p6" src="https://github.com/user-attachments/assets/40346dc7-e156-441d-96af-ff268c0b7792" />
<img width="1182" height="471" alt="main_p7" src="https://github.com/user-attachments/assets/2316d472-9717-4dde-9759-50d3b82a056a" />


# Banco de Dados: Sql Server

## Está dividido em quatro áreas principais de responsabilidade de um DBA

**Segurança: Scripts para a criação de um modelo de segurança robusto, aplicando o princípio do menor privilégio**

**1. create_login_user_script.sql: Criação de Login (Nível instância) e Usuário (Nível Banco)**

<img width="1335" height="913" alt="create_Login_p1" src="https://github.com/user-attachments/assets/0ae75f57-6a24-471b-b714-c288061ed78b" />
<img width="1361" height="648" alt="create_Login_p2" src="https://github.com/user-attachments/assets/661bca6c-1cec-4675-9bfb-4c0d08d9a990" />
<img width="1375" height="901" alt="create_Login_p3" src="https://github.com/user-attachments/assets/0c310f1e-618f-4b96-9be4-394fae971a9f" />


**1.1. usp_get_failed_logins_report.sql: Stored Procedure para auditar tentativas mal sucedidas de login**

<img width="1135" height="920" alt="audit login01" src="https://github.com/user-attachments/assets/a7d30cc3-bdd1-4faf-8bf1-fddd7ade284a" />
<img width="1137" height="932" alt="audit login02" src="https://github.com/user-attachments/assets/a5371824-bfbd-4c23-af50-b6d9d198e928" />
<img width="1800" height="259" alt="audit_result" src="https://github.com/user-attachments/assets/6c71d3ea-411c-45da-bbe2-2193721642cf" />

**1.2. Automação de execução do main_etl usando Task Schedule do Windows**

<img width="1790" height="1014" alt="task_schedule_01" src="https://github.com/user-attachments/assets/74655a26-d9a8-451b-909b-e86031cebe98" />
<img width="1381" height="617" alt="task_schedule_02" src="https://github.com/user-attachments/assets/2ca2e92d-c185-4c33-a939-4366c96785c2" />


**1.2.1. launcher.bat e deploy_and_run_etl: Arquivos criados para driblar erro de caminho longo no ambiente virtual Poetry**

<img width="1627" height="305" alt="launcher bat" src="https://github.com/user-attachments/assets/964ce106-4a88-4d65-8bb8-dc111df7277e" />
<img width="781" height="875" alt="launcher bat 2" src="https://github.com/user-attachments/assets/2a5b86a8-f7e7-4e8c-b5a7-b146edf1db2c" />


**Backup e Recuperação:** Estratégia de backup para garantir a recuperabilidade dos dados e minimizar a perda em caso de desastre (RPO/RTO).

**Automação e Manutenção:** Rotinas para garantir a "saúde" do banco de dados a longo prazo, como manutenção de índices e atualização de estatísticas.

**Performance e Otimização:** Um case prático de diagnóstico e resolução de um problema de performance em uma consulta.

# Tecnologias

* Microsoft SQL Server

* Transact-SQL (T-SQL)

* SQL Server Management Studio (SSMS)

* Vscode

* Python

* Git

* Power BI

# Estrutura do Repositório: sqlserver_administrator


<img width="503" height="497" alt="Captura de tela 2025-09-01 151723" src="https://github.com/user-attachments/assets/eff29f55-0f0b-4e70-97b2-184504e3c730" />
