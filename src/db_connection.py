"""
Módulo de conexión a la base de datos del proyecto.
Lee las credenciales desde variables de entorno (.env) — nunca hardcodeadas.
"""

import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

CONNECTION_STRING = f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

def get_engine():
    """Devuelve un SQLAlchemy engine conectado a ecommerce_db."""
    return create_engine(CONNECTION_STRING)

if __name__ == "__main__":
    engine = get_engine()
    with engine.connect() as conn:
        result = conn.execute(text("SELECT version();"))
        print("Conexión exitosa. Versión de PostgreSQL:")
        print(result.fetchone()[0])
