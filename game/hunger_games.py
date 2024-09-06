import psycopg2

# Dados de conexão
conn = psycopg2.connect(
    dbname="hunger_games",
    user="postgres",
    password="20082003",
    host="localhost",
    port="5432"
)

# Criar um cursor
cur = conn.cursor()

# Executar uma consulta
cur.execute("SELECT * FROM sala")

# Buscar os resultados
rows = cur.fetchall()

# Imprimir resultados
for row in rows:
    print(row)

# Fechar a conexão
cur.close()
conn.close()
