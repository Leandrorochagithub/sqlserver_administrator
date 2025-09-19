# Segurança: Scripts para a criação de um modelo de segurança robusto, aplicando o princípio do menor privilégio

**1.1 create_login_user_script.sql: Criação de Login (Nível instância) e Usuário (Nível Banco)**

<img width="840" height="117" alt="loginuser" src="https://github.com/user-attachments/assets/da08300b-8e55-4e9d-baf0-18195ba9b3b0" />

**1.2. usp_get_failed_logins_report.sql: Stored Procedure para auditar tentativas mal sucedidas de login**

<img width="1800" height="259" alt="audit_result" src="https://github.com/user-attachments/assets/154f1a00-e945-4b37-afe2-bb4854481614" />

**1.3. Automação de execução do main_etl usando Task Schedule do Windows**
<img width="1790" height="1014" alt="task_schedule_01" src="https://github.com/user-attachments/assets/531a2c56-cb0a-4d6f-9e42-a92361aaeae4" />
<img width="1381" height="617" alt="task_schedule_02" src="https://github.com/user-attachments/assets/975bd96f-d697-433d-b2c7-08286dc8b1df" />

**1.3.1. launcher.bat e deploy_and_run_etl: Arquivos criados para driblar erro de caminho longo no ambiente virtual Poetry**
