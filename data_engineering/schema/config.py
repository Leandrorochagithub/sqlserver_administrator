# config.py
# Este arquivo centraliza todas as configurações do projeto.
# This file centralizes all project configurations.

# IMPORTANTE: Altere para o nome da sua instância do SQL Server.
# IMPORTANT: Change to your SQL Server instance name.
SERVER_NAME = 'localhost\SQLEXCHANGERATE' 
DATABASE_NAME = 'CryptoDB'
USER_NAME = 'app_etl_crypto'
USER_PASSWORD = 'q1w2e3r4'
API_RESPONSES_FOLDER = "backup_api_responses"
DAYS_TO_FETCH = 90
COINS_TO_TRACK = {
    'bitcoin': {'symbol': 'btc', 'name': 'Bitcoin'},
    'ethereum': {'symbol': 'eth', 'name': 'Ethereum'},
    'cardano': {'symbol': 'ada', 'name': 'Cardano'},
    'dogecoin': {'symbol': 'doge', 'name': 'Dogecoin'},
    'solana': {'symbol': 'sol', 'name': 'Solana'},
    'ripple': {'symbol': 'xrp', 'name': 'XRP'},
    'polkadot': {'symbol': 'dot', 'name': 'Polkadot'},
    'chainlink': {'symbol': 'link', 'name': 'Chainlink'},
    'polygon': {'symbol': 'matic', 'name': 'Polygon'},
    'litecoin': {'symbol': 'ltc', 'name': 'Litecoin'},
    'uniswap': {'symbol': 'uni', 'name': 'Uniswap'},
    'cosmos': {'symbol': 'atom', 'name': 'Cosmos'},
    'stellar': {'symbol': 'xlm', 'name': 'Stellar'},
    'avalanche-2': {'symbol': 'avax', 'name': 'Avalanche'},
    'shiba-inu': {'symbol': 'shib', 'name': 'Shiba Inu'},
    'tron': {'symbol': 'trx', 'name': 'TRON'},
    'monero': {'symbol': 'xmr', 'name': 'Monero'},
    'aave': {'symbol': 'aave', 'name': 'Aave'},
    'maker': {'symbol': 'mkr', 'name': 'Maker'},
    'the-sandbox': {'symbol': 'sand', 'name': 'The Sandbox'},
    'decentraland': {'symbol': 'mana', 'name': 'Decentraland'},
    'fantom': {'symbol': 'ftm', 'name': 'Fantom'},
    'hedera-hashgraph': {'symbol': 'hbar', 'name': 'Hedera'},
    'algorand': {'symbol': 'algo', 'name': 'Algorand'},
    'tezos': {'symbol': 'xtz', 'name': 'Tezos'}
}

# \--- EMAIL ALERT CONFIGURATION ---
# IMPORTANTE: Preencha com as suas informações. / IMPORTANT: Fill with your information.
# Se usar o Gmail, você precisará de gerar uma "Senha de App". Veja a nota abaixo.
# If using Gmail, you will need to generate an "App Password." See the note below.

EMAIL_CONFIG = {
    "SMTP_SERVER": "smtp.gmail.com",
    "SMTP_PORT": 587,
    "SENDER_EMAIL": "leandrodarochaferreira@gmail.com",
    "SENDER_PASSWORD": "awum ngap exlm crug",
    "RECIPIENT_EMAIL": "leandrodarochaferreira@gmail.com"
}