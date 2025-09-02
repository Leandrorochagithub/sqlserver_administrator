import pyodbc # to connect with sql server
import os # to manipulate folders
from config import SERVER_NAME, DATABASE_NAME, USER_NAME, USER_PASSWORD # importation from config file

# --- CONNECTION CINFIGURATION ---
SCHEMA_FILE = '1_schema.sql' 

# --- PATH LOGIC FOR IMPORTS ---
script_dir = os.path.dirname(__file__) # Add the '2_schema' folder to the Python path
parent_dir = os.path.dirname(script_dir) # so it can find the config.py file
config_dir_path = os.path.join(parent_dir, '2_schema') # Mounts the path to the folder where config.py is
sys.path.append(config_dir_path)

master_conn_str = (
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={SERVER_NAME};"
    f"DATABASE=master;"
    f"UID={USER_NAME};"
    f"PWD={USER_PASSWORD};"
)

# Connection string for our 'CryptoDB' database
db_conn_str = (
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={SERVER_NAME};"
    f"DATABASE={DATABASE_NAME};"
    f"UID={USER_NAME};"  
    f"PWD={USER_PASSWORD};" 
)

def build_database():
    """
    Conecta-se ao SQL Server, cria o banco de dados 'CryptoDB' (se não existir)
    e executa o schema.sql para criar as tabelas.
    """
    conn = None
    try:
        # 1. Connect to the 'master' to create the database
        conn = pyodbc.connect(master_conn_str, autocommit=True)
        cursor = conn.cursor()
        print(f"Conectado ao servidor '{SERVER_NAME}'. Verificando banco de dados '{DATABASE_NAME}'...")

        # Check if the database already exists and, if so, delete it for a clean start.
        cursor.execute(f"IF DB_ID('{DATABASE_NAME}') IS NOT NULL DROP DATABASE {DATABASE_NAME}")
        print(f"Banco de dados antigo '{DATABASE_NAME}' (se existiu) foi removido.")
        
        # 3. Create the new database
        cursor.execute(f"CREATE DATABASE {DATABASE_NAME}")
        print(f"Banco de dados '{DATABASE_NAME}' criado com sucesso.")
        conn.close()

        # 4. Connect to the new 'CryptoDB' database to create the tables
        print(f"Conectando ao banco '{DATABASE_NAME}' para criar tabelas...")
        conn = pyodbc.connect(db_conn_str)
        cursor = conn.cursor()

        script_dir = os.path.dirname(__file__)
        schema_path = os.path.join(script_dir, SCHEMA_FILE)

        with open(schema_path, 'r') as f:
            # .split('GO') is needed because pyodbc doesn't understand the 'GO' command
            schema_script = f.read().split('GO')
        
        for statement in schema_script:
            if statement.strip():
                cursor.execute(statement)
        
        print("Schema executado e tabelas criadas com sucesso.")
        conn.commit()

    except pyodbc.Error as e:
        print(f"Ocorreu um erro no banco de dados: {e}")
    except FileNotFoundError:
        print(f"Erro: O arquivo '{SCHEMA_FILE}' não foi encontrado.")
    except Exception as e:
        print(f"Ocorreu um erro inesperado: {e}")
    finally:
        if conn:
            conn.close()
            print("Conexão com o banco de dados fechada.")


if __name__ == "__main__":
    build_database()
