# Portfólio de Administração de Banco de Dados SQL Server

Este repositório contém uma coleção de scripts e análises que demonstram as competências essenciais de um Administrador de Banco de Dados (DBA). O objetivo é aplicar os princípios de segurança, backup, manutenção e otimização de performance em um banco de dados de projeto.
Estrutura do Projeto.

# Este laboratório está dividido em quatro áreas principais de responsabilidade de um DBA:

Segurança: Scripts para a criação de um modelo de segurança robusto, aplicando o princípio do menor privilégio.
Backup e Recuperação: Estratégia de backup para garantir a recuperabilidade dos dados e minimizar a perda em caso de desastre (RPO/RTO).
Automação e Manutenção: Rotinas para garantir a "saúde" do banco de dados a longo prazo, como manutenção de índices e atualização de estatísticas.
Performance e Otimização: Um case prático de diagnóstico e resolução de um problema de performance em uma consulta.

# Tecnologias

Microsoft SQL Server
Transact-SQL (T-SQL)
SQL Server Management Studio (SSMS)
Vscode
Python

Estrutura do Repositório: DBA-Lab-Project
/DBA-Lab-Project
├── 1_Seguranca/
│   ├── criar_logins_e_usuarios.sql
│   └── README.md
├── 2_Backup_e_Recuperacao/
│   ├── job_backup_full.sql
│   ├── job_backup_log.sql
│   └── README.md
├── 3_Automacao_e_Manutencao/
│   ├── job_manutencao_indices_estatisticas.sql
│   └── README.md
├── 4_Performance_e_Otimizacao/
│   ├── cenario_problema.sql
│   ├── analise_plano_execucao.md
│   └── cenario_solucao.sql
└── README.md  
