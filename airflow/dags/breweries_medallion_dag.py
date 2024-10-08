# dags/breweries_medallion_dag.py

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.hooks.base import BaseHook
from datetime import datetime, timedelta

# Importar funções dos scripts modularizados
from scripts.fetch_breweries import fetch_breweries
from scripts.transform_silver import transform_to_silver
from scripts.aggregate_gold import aggregate_gold

# Definição de argumentos padrão para a DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email': ['yuri.placido98@gmail.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Obter as credenciais AWS uma vez
aws_connection = BaseHook.get_connection('aws_default')
aws_access_key = aws_connection.login
aws_secret_key = aws_connection.password
aws_region = aws_connection.extra_dejson.get('region_name', 'sa-east-1')

# Inicialização da DAG
with DAG(
    'breweries_medallion_dag',
    default_args=default_args,
    description='Pipeline de Dados para Breweries seguindo a arquitetura de Medallion',
    schedule_interval=timedelta(days=1),
    start_date=datetime(2024, 1, 1),
    catchup=False,
) as dag:

    # Tarefa: Extrair Dados da API e Salvar no S3 (Bronze Layer)
    fetch_breweries_task = PythonOperator(
        task_id='fetch_breweries',
        python_callable=fetch_breweries,
        op_kwargs={
            'aws_access_key': aws_access_key,
            'aws_secret_key': aws_secret_key,
            'aws_region': aws_region,
        },
    )

    # Tarefa: Transformar Dados para a Camada Silver
    transform_to_silver_task = PythonOperator(
        task_id='transform_to_silver',
        python_callable=transform_to_silver,
        op_kwargs={
            'aws_access_key': aws_access_key,
            'aws_secret_key': aws_secret_key,
            'aws_region': aws_region,
        },
    )

    # Tarefa: Agregar Dados para a Camada Gold
    aggregate_gold_task = PythonOperator(
        task_id='aggregate_gold',
        python_callable=aggregate_gold,
        op_kwargs={
            'aws_access_key': aws_access_key,
            'aws_secret_key': aws_secret_key,
            'aws_region': aws_region,
        },
    )

    # Definição da ordem das tarefas
    fetch_breweries_task >> transform_to_silver_task >> aggregate_gold_task
