import requests
import pyodbc
import json
import os
import sys
from datetime import datetime
import time

# --- LÓGICA DE CAMINHOS PARA IMPORTS ---
# Adiciona a pasta '1_schema' ao caminho do Python para que ele possa encontrar o config.py
script_dir = os.path.dirname(__file__)
parent_dir = os.path.dirname(script_dir)
config_dir_path = os.path.join(parent_dir, '1_schema')
sys.path.append(config_dir_path)

# Importa TODAS as configurações do arquivo config.py
from config import SERVER_NAME, DATABASE_NAME, API_RESPONSES_FOLDER, COINS_TO_TRACK, DAYS_TO_FETCH

# --- CONFIGURAÇÃO DA CONEXÃO ---
CONNECTION_STRING = (
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={SERVER_NAME};"
    f"DATABASE={DATABASE_NAME};"
    f"Trusted_Connection=yes;"
)

# --- FUNÇÕES DO BANCO DE DADOS ---
# (As funções do banco de dados continuam as mesmas)
def insert_coin_data(conn, coin_id, symbol, name):
    cursor = conn.cursor()
    merge_sql = """
    MERGE INTO coins AS target
    USING (VALUES (?, ?, ?)) AS source (id, symbol, name)
    ON (target.id = source.id)
    WHEN NOT MATCHED THEN
        INSERT (id, symbol, name) VALUES (source.id, source.symbol, source.name);
    """
    cursor.execute(merge_sql, coin_id, symbol, name)
    print(f"Moeda '{name}' verificada/inserida na tabela 'coins'.")

def insert_price_history(conn, coin_id, records_to_insert):
    cursor = conn.cursor()
    sql = "INSERT INTO price_history (coin_id, price_date, price_usd, market_cap_usd, volume_usd) VALUES (?, ?, ?, ?, ?)"
    cursor.executemany(sql, records_to_insert)
    print(f"Inseridos {len(records_to_insert)} registros históricos para {coin_id}.")

def get_total_records_count(conn):
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM price_history;")
    total_records = cursor.fetchone()[0]
    print(f"\n--- Verificação Final ---")
    print(f"Total de registros na tabela 'price_history': {total_records}")


# --- FUNÇÕES DA API E TRANSFORMAÇÃO ---
def fetch_and_save_coin_history(coin_id, days):
    url = f"https://api.coingecko.com/api/v3/coins/{coin_id}/market_chart?vs_currency=usd&days={days}"
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        print(f"Dados para '{coin_id}' extraídos com sucesso da API.")

        backup_folder_path = os.path.join(script_dir, API_RESPONSES_FOLDER)
        if not os.path.exists(backup_folder_path):
            os.makedirs(backup_folder_path)
        
        file_path = os.path.join(backup_folder_path, f"{coin_id}_history.json")
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=4)
        print(f"Backup dos dados salvo em: {file_path}")
        
        return data

    except requests.exceptions.RequestException as e:
        print(f"Erro ao buscar dados para {coin_id}: {e}")
        return None

def transform_data_for_db(coin_id, api_data):
    prices = api_data.get('prices', [])
    market_caps = api_data.get('market_caps', [])
    volumes = api_data.get('total_volumes', [])

    if not (prices and market_caps and volumes):
        print(f"Dados históricos incompletos para {coin_id}.")
        return []

    records_to_insert = []
    for i in range(len(prices)):
        timestamp = prices[i][0] / 1000
        price_date_obj = datetime.fromtimestamp(timestamp)
        price_usd = prices[i][1]
        market_cap_usd = market_caps[i][1]
        volume_usd = volumes[i][1]
        
        records_to_insert.append((coin_id, price_date_obj, price_usd, market_cap_usd, volume_usd))
    
    return records_to_insert

# --- FLUXO PRINCIPAL (MAIN) ---
def main():
    print("Iniciando o processo de ETL para SQL Server...")
    conn = None
    try:
        conn = pyodbc.connect(CONNECTION_STRING)
        print(f"Conectado ao banco de dados: '{DATABASE_NAME}' no servidor '{SERVER_NAME}'")

        for coin_id, coin_info in COINS_TO_TRACK.items():
            print(f"\n--- Processando {coin_info['name']} ---")
            
            insert_coin_data(conn, coin_id, coin_info['symbol'], coin_info['name'])
            
            historical_data = fetch_and_save_coin_history(coin_id, days=DAYS_TO_FETCH)
            
            if historical_data:
                transformed_records = transform_data_for_db(coin_id, historical_data)
                
                if transformed_records:
                    insert_price_history(conn, coin_id, transformed_records)
            
            print("Pausa de 10 segundos para respeitar o limite da API...")
            time.sleep(10)

        get_total_records_count(conn)
        conn.commit()

    except pyodbc.Error as e:
        print(f"Ocorreu um erro no banco de dados: {e}")
    finally:
        if conn:
            conn.close()
            print("\nConexão com o banco de dados fechada.")
    
    print("Processo de ETL concluído.")


if __name__ == "__main__":
    main()