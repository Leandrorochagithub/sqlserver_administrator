import requests
import pyodbc
import json
import os
from datetime import datetime
import time
import sys
import smtplib
from email.message import EmailMessage
import traceback

# --- LÓGICA DE CAMINHOS PARA IMPORTS ---
# Adiciona a pasta 'schema' ao caminho do Python
# para que ele possa encontrar o arquivo config.py
script_dir = os.path.dirname(__file__)
parent_dir = os.path.dirname(script_dir)
config_dir_path = os.path.join(parent_dir, 'schema')
sys.path.append(config_dir_path)

from config import SERVER_NAME, DATABASE_NAME, USER_NAME, USER_PASSWORD, COINS_TO_TRACK, API_RESPONSES_FOLDER, EMAIL_CONFIG

# --- CONFIGURAÇÃO DA CONEXÃO ---
CONNECTION_STRING = (
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={SERVER_NAME};"
    f"DATABASE={DATABASE_NAME};"
    f"UID={USER_NAME};"
    f"PWD={USER_PASSWORD};"
)

# --- FUNÇÃO DE ALERTA POR E-MAIL ---

def send_failure_email(error_traceback):
    """Envia um e-mail de alerta em caso de falha no ETL."""
    msg = EmailMessage()
    msg.set_content(f"""Olá,\nO pipeline de ETL de Criptomoedas falhou em {datetime.now()}.Detalhes do erro:\n\--------------------\n{error_traceback}""")
    msg['From'] = EMAIL_CONFIG["SENDER_EMAIL"]
    msg['To'] = EMAIL_CONFIG["RECIPIENT_EMAIL"]
    msg['Subject'] = '[ALERTA] Falha no Pipeline de ETL de Criptomoedas'
    try:
        print("Tentando enviar e-mail de alerta...")
        with smtplib.SMTP(EMAIL_CONFIG["SMTP_SERVER"], EMAIL_CONFIG["SMTP_PORT"]) as server:
            server.starttls()
            server.login(EMAIL_CONFIG["SENDER_EMAIL"], EMAIL_CONFIG["SENDER_PASSWORD"])
            server.send_message(msg)
            print("E-mail de alerta enviado com sucesso.")
    except Exception as e:
            print(f"Falha ao enviar o e-mail de alerta: {e}")

# --- FUNÇÕES DO BANCO DE DADOS ---
def insert_coin_data(conn, coin_id, symbol, name):
    """Insere os dados de uma moeda na tabela 'dbo.coins'."""
    cursor = conn.cursor()
    # SQL Server usa 'MERGE' para fazer um "INSERT se não existir"
    # Usamos o nome explícito 'dbo.coins' para remover ambiguidade.
    merge_sql = """
    MERGE INTO dbo.coins AS target
    USING (VALUES (?, ?, ?)) AS source (id, symbol, name)
    ON (target.id = source.id)
    WHEN NOT MATCHED THEN
        INSERT (id, symbol, name) VALUES (source.id, source.symbol, source.name);
    """
    cursor.execute(merge_sql, coin_id, symbol, name)
    print(f"Moeda '{name}' verificada/inserida na tabela 'dbo.coins'.")

def insert_price_history(conn, coin_id, records_to_insert):
    """Insere uma lista de registros históricos de preço no banco."""
    cursor = conn.cursor()
    # Usamos o nome explícito 'dbo.price_history' para remover ambiguidade.
    sql = "INSERT INTO dbo.price_history (coin_id, price_date, price_usd, market_cap_usd, volume_usd) VALUES (?, ?, ?, ?, ?)"
    cursor.executemany(sql, records_to_insert)
    print(f"Inseridos {len(records_to_insert)} registros históricos para {coin_id}.")

def get_total_records_count(conn):
    """
    Executa uma consulta para contar o número total de registros na tabela
    dbo.price_history e imprime o resultado.
    """
    cursor = conn.cursor()
    # Usamos o nome explícito 'dbo.price_history' para remover ambiguidade.
    cursor.execute("SELECT COUNT(*) FROM dbo.price_history;")
    total_records = cursor.fetchone()[0]
    print(f"\n--- Verificação Final ---")
    print(f"Total de registros na tabela 'dbo.price_history': {total_records}")

# --- FUNÇÕES DA API E TRANSFORMAÇÃO ---
def fetch_and_save_coin_history(coin_id, days=7):
    """
    Busca o histórico de mercado de uma moeda na API da CoinGecko e salva em um arquivo JSON.
    """
    url = f"https://api.coingecko.com/api/v3/coins/{coin_id}/market_chart?vs_currency=usd&days={days}"
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        data = response.json()
        print(f"Dados para '{coin_id}' extraídos com sucesso da API.")

        script_dir = os.path.dirname(__file__)
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
    """Transforma os dados brutos da API em um formato pronto para o banco de dados."""
    prices = api_data.get('prices', [])
    market_caps = api_data.get('market_caps', [])
    volumes = api_data.get('total_volumes', [])

    if not (prices and market_caps and volumes):
        print(f"Dados históricos incompletos para {coin_id}.")
        return []

    records_to_insert = []
    for i in range(len(prices)):
        timestamp = prices[i][0] / 1000
        # pyodbc pode lidar com objetos datetime diretamente, o que é mais robusto.
        price_date_obj = datetime.fromtimestamp(timestamp)
        price_usd = prices[i][1]
        market_cap_usd = market_caps[i][1]
        volume_usd = volumes[i][1]
        
        records_to_insert.append((coin_id, price_date_obj, price_usd, market_cap_usd, volume_usd))
    
    return records_to_insert

# --- FLUXO PRINCIPAL (MAIN) ---
def main():
    """Orquestra o processo completo de ETL."""
    print("Iniciando o processo de ETL para SQL Server...")
    conn = None
    try:
        # Linha de teste de envio de e-mail em casa de falha no etl.
        # raise ValueError("Este é um erro de teste para o alerta de e-mail.")
        conn = pyodbc.connect(CONNECTION_STRING)
        print(f"Conectado ao banco de dados: '{DATABASE_NAME}' no servidor '{SERVER_NAME}'")

        for coin_id, coin_info in COINS_TO_TRACK.items():
            print(f"\n--- Processando {coin_info['name']} ---")
            
            insert_coin_data(conn, coin_id, coin_info['symbol'], coin_info['name'])
            
            historical_data = fetch_and_save_coin_history(coin_id, days=90)
            
            if historical_data:
                transformed_records = transform_data_for_db(coin_id, historical_data)
                
                if transformed_records:
                    insert_price_history(conn, coin_id, transformed_records)
            
            print("Pausa de 10 segundos para respeitar o limite da API...")
            time.sleep(10)

        get_total_records_count(conn)
        conn.commit()

    except Exception as e:
        print("\n!!!!!!!!!! OCORREU UMA FALHA NO PROCESSO DE ETL !!!!!!!!!!")
        error_details = traceback.format_exc()
        print(error_details)
        send_failure_email(error_details)
        if conn:
            conn.rollback()
    finally:
        if 'conn' in locals() and conn:
            conn.close()
            print("\nConexão com o banco de dados fechada.")
            print("Fim da execução do script.")

if __name__ == "__main__":
    main()
