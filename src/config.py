from dataclasses import dataclass
from dotenv import dotenv_values
import os

RAW_CONFIG = {
    **dotenv_values('.env'),
    **dotenv_values('.env.local'),
    **os.environ
}

def get_config(key, default=None):
    result = RAW_CONFIG.get(key, default)
    if result is None:
        print(f'Could not find required config for {key}')
    return result

@dataclass
class Config:
    CLIENT_ID = get_config('CLIENT_ID')
    CLIENT_SECRET = get_config('CLIENT_SECRET')
    BCDA_ENV = get_config('BCDA_ENV', 'sandbox') # api or sandbox
    DATASET_NAME = get_config('DATASET_NAME')
    AUTHENTICATOR = get_config('AUTHENTICATOR', 'snowflake')
    USER = get_config('USER')
    PASSWORD = get_config('PASSWORD', '')
    ACCOUNT = get_config('ACCOUNT')
    DATABASE = get_config('DATABASE')
    SCHEMA = get_config('SCHEMA')
    WAREHOUSE = get_config('WAREHOUSE')
    ROLE = get_config('ROLE')

CONFIG = Config()
