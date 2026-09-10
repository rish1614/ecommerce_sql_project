from pathlib import Path
import csv
import psycopg2

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
SCHEMA = ROOT / "sql" / "01_schema.sql"

conn = psycopg2.connect(
    host="localhost",
    port=5432,
    dbname="ecommerce_analytics",
    user="analyst",
    password="analyst",
)
conn.autocommit = False

try:
    with conn.cursor() as cur:
        cur.execute(SCHEMA.read_text(encoding="utf-8"))
        for table in ["customers", "products", "campaigns", "orders", "order_items", "returns"]:
            csv_path = DATA / f"{table}.csv"
            with csv_path.open("r", encoding="utf-8") as f:
                cur.copy_expert(f"COPY {table} FROM STDIN WITH CSV HEADER", f)
    conn.commit()
    print("Schema created and CSVs loaded successfully.")
except Exception:
    conn.rollback()
    raise
finally:
    conn.close()
