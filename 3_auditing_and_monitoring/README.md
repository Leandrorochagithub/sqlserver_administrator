# Auditoria de Segurança - Monitoramento de Logins Falhos

## 🎯 Objetivo

Um dos pilares da segurança de um banco de dados é o monitoramento proativo de atividades suspeitas. Tentativas de login com falha podem indicar um ataque de força bruta, uma tentativa de acesso não autorizado ou uma aplicação mal configurada.

Este script foi desenvolvido para auditar o log de erros do SQL Server e gerar um relatório consolidado das tentativas de login que falharam nos últimos 7 dias, identificando **qual usuário**, **de qual endereço IP** e **quantas vezes** a tentativa ocorreu.

## 🛠️ A Ferramenta: `auditoria_logins_falhos.sql`

O script `auditoria_logins_falhos.sql` executa os seguintes passos:

1.  **Enumera os Logs:** Identifica todos os arquivos de log de erro disponíveis no servidor.
2.  **Leitura Eficiente:** Percorre cada arquivo de log, pré-filtrando as entradas para ler apenas as que contêm as palavras-chave "Login" e "failed", otimizando a performance.
3.  **Extração de Dados:** Analisa a mensagem de erro para extrair informações cruciais como o `LoginName` e o `ClientIP`.
4.  **Relatório Consolidado:** Agrupa os dados para fornecer um sumário claro, ordenado pelo número de tentativas, mostrando imediatamente os alvos mais frequentes.

## 📊 Resultado da Simulação

Abaixo está um exemplo do relatório gerado pelo script após a simulação de algumas tentativas de login incorretas. O resultado permite identificar rapidamente um possível ataque de força bruta ao usuário `app_etl_crypto` vindo de um IP local.


<img width="1800" height="259" alt="audit_result" src="https://github.com/user-attachments/assets/9fba9386-9d34-40ca-bd55-d1f1d91bc358" />


## ✨ Habilidades Demonstradas

* **T-SQL Avançado:** Uso de variáveis de tabela, procedures de sistema (`sp_enumerrorlogs`, `sp_readerrorlog`), loops (`WHILE`) e Common Table Expressions (CTEs).
* **Segurança e Auditoria:** Compreensão da importância do monitoramento de segurança e da análise dos logs do SQL Server.
* **Análise de Dados com SQL:** Capacidade de transformar dados de log não estruturados em um relatório de inteligência acionável.
* **Otimização de Consultas:** Pré-filtragem de dados para garantir a eficiência do script em ambientes com logs grandes.
