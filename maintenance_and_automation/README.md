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

## Maintenance Plan:

<img width="450" height="350" alt="Captura de tela 2025-10-10 145946" src="https://github.com/user-attachments/assets/3bb5450e-a22b-40c5-8990-9b47cfaf73df" />
<br>
<img width="450" height="350" alt="Captura de tela 2025-10-10 150210" src="https://github.com/user-attachments/assets/32feaf62-3347-4a91-9c6e-40a99bd5c94e" />

## Execução:
**Executando...**

<img width="450" height="350" alt="Captura de tela 2025-10-10 154642" src="https://github.com/user-attachments/assets/f205470a-fe36-43af-809e-9df16563e5c5" />


**Arquivo que Log direcionando para pasta específica:**


<img width="450" height="350" alt="Captura de tela 2025-10-10 154738" src="https://github.com/user-attachments/assets/6c15ecc8-75c6-4442-bcd4-2c44ed7a4412" />


