import pymysql
import os

def lambda_handler(event, context):
    # Configurações do banco de dados
    host = os.environ['DB_HOST']
    user = os.environ['DB_USER']
    password = os.environ['DB_PASSWORD']
    database = os.environ['DB_NAME']

    # Ler o script SQL do arquivo local
    with open('script_criacao_tabelas.sql', 'r') as file:
        sql_script = file.read()

    # Conectar ao banco de dados
    conn = pymysql.connect(host=host, user=user, password=password, database=database)
    cursor = conn.cursor()

    try:
        # Executar o script SQL
        for statement in sql_script.split(';'):
            if statement.strip():
                cursor.execute(statement)
        
        conn.commit()
        return {
            'statusCode': 200,
            'body': 'Script SQL executado com sucesso!'
        }
    except Exception as e:
        conn.rollback()
        return {
            'statusCode': 500,
            'body': f'Erro ao executar o script SQL: {str(e)}'
        }
    finally:
        cursor.close()
        conn.close()