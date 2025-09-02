import pyodbc
import os
import sys

script_dir = os.path.dirname(__file__)
parent_dir = os.path.dirname(script_dir)
config_dir_path = os.path.join(parent_dir, '1_schema')
sys.path.append(config_dir_path)

try:
    # Importa as configurações. Se o config.py não for encontrado
    # este será o ponto de falha.
    # Imports the settings. If config.py isn't found
    # this will be the point of failure.
    from config import SERVER_NAME, DATABASE_NAME, USER_NAME, USER_PASSWORD
except ImportError:
    print("Erro: Não foi possível encontrar o arquivo 'config.py'.")
    print(f"Verifique se o arquivo está na pasta: {config_dir_path}")
    sys.exit(1) # Encerra o script com um código de erro

# --- CONSTRUÇÃO DA STRING DE CONEXÃO ---
# Monta a string de conexão exatamente como no script principal.
# --- CONNECTION STRING CONSTRUCTION ---
# Builds the connection string exactly as in the main script.
CONNECTION_STRING = (
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={SERVER_NAME};"
    f"DATABASE={DATABASE_NAME};"
    f"UID={USER_NAME};"
    f"PWD={USER_PASSWORD};"
)

# --- TENTATIVA DE CONEXÃO ---
# Tenta conectar ao banco de dados e reporta o sucesso ou a falha.
# --- CONNECTION ATTEMPT ---
# Tries to connect to the database and reports success or failure.
conn = None
try:
    print(f"Tentando conectar ao servidor '{SERVER_NAME}'...")
    conn = pyodbc.connect(CONNECTION_STRING)
    print("\n✅ Conexão bem-sucedida!")
    print("As suas credenciais e a string de conexão estão corretas.")

except pyodbc.Error as ex:
    sqlstate = ex.args[0]
    print("\n❌ Falha na conexão!")
    print(f"SQLSTATE: {sqlstate}")
    print(f"Erro: {ex}")
    print("\nPossíveis causas:")
    print("- Senha ou nome de usuário incorretos no config.py.")
    print("- O serviço do SQL Server não está em execução.")
    print("- Firewall bloqueando a conexão.")
    print("- Nome do servidor incorreto no config.py.")

finally:
    if conn:
        conn.close()
        print("\nConexão fechada.")