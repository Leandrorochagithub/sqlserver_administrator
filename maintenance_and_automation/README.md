# Manutenção Preventiva Semanal

## Objetivo: 

**Com o tempo e o uso (milhares de INSERT, UPDATE, DELETE), podem resultar em:**

* Ineficiência (Fragmentação de Índices): Acessar os dados se torna mais lento.
* Desatualização (Estatísticas Desatualizadas): O sistema começa a escolher rotas ineficientes para buscar os dados.
* Corrupção de Dados: Uma pequena falha de hardware ou bug pode corromper dados de forma silenciosa.

**A manutenção preventiva ataca exatamente esses três pontos para manter o Banco saudável.**

## Ferramenta Utilizada: 

* Plano de Manutenção do SQL Server.

## Tarefas Agendadas: 

* 1º: Verificação de Integridade (Check Database Integrity - DBCC CHECKDB)
* 2º: Reconstruir Índices (Rebuild Index)
* 3º: Atualizar Estatísticas (Update Statistics)
* Frequência: Semanal, Domingos
