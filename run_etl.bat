@echo OFF
ECHO =================================================================
ECHO      PROCESSO DE DEPLOY E EXECUCAO DO ETL DE CRIPTOMOEDAS
ECHO =================================================================
echo.

REM --- CONFIGURACAO ---
REM Define o caminho do codigo-fonte (seu Google Drive)
SET SOURCE\_DIR="G:\\My Drive\\personal\_studies\\sql\_server\\sqlserver\_admin\_portfolio"

REM Define um local seguro no disco C: para a execucao
SET EXECUTION\_DIR="C:\\temp\_etl\_execution"

echo.
ECHO --- PASSO 1: FAZENDO O DEPLOY (COPIANDO ARQUIVOS) ---
ECHO Fonte: %SOURCE\_DIR%
ECHO Destino: %EXECUTION\_DIR%
echo.

REM Cria o diretorio de execucao se ele nao existir
IF NOT EXIST %EXECUTION\_DIR% (
ECHO Criando diretorio de execucao...
mkdir %EXECUTION\_DIR%
)

REM Robocopy e uma ferramenta robusta para copiar/sincronizar pastas.
REM /E copia subdiretorios, incluindo os vazios.
REM /MIR "espelha" o diretorio, apagando ficheiros no destino que ja nao existem na fonte.
robocopy %SOURCE\_DIR% %EXECUTION\_DIR% /E /MIR /NFL /NDL /NJH /NJS /nc /ns /np

ECHO Deploy concluido.
echo.

REM --- PASSO 2: EXECUTANDO O ETL A PARTIR DO LOCAL SEGURO ---
ECHO Navegando para o diretorio de execucao...
cd /D %EXECUTION\_DIR%

ECHO Ativando o ambiente Poetry e executando o script de ETL...
echo.

REM Executa o script Python usando o 'poetry run'.
REM Como estamos no diretorio de execucao, o Task Scheduler nao tera problemas de permissao.
poetry run python data\_engineering/main\_etl/main\_etl\_sqlserver.py

echo.
ECHO --- PROCESSO CONCLUIDO ---