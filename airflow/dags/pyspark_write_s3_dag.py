from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.hooks.base import BaseHook
from datetime import datetime
from pyspark.sql import SparkSession
import os

def write_to_s3():
    try:
        # Recuperar as credenciais AWS diretamente da conexão 'aws_default'
        aws_conn = BaseHook.get_connection('aws_default')
        aws_access_key = aws_conn.login
        aws_secret_key = aws_conn.password
        aws_region = aws_conn.extra_dejson.get('region_name', 'sa-east-1')
        
        # Obter o nome do bucket a partir de variáveis de ambiente
        bronze_bucket = os.getenv('BRONZE_BUCKET_NAME', 'breweries-data-pipeline-bronze-dev')
        
        # Inicializar a sessão Spark com as credenciais AWS diretamente
        spark = SparkSession.builder \
            .appName("AirflowPySparkJob") \
            .config("spark.jars", "/opt/airflow/jars/hadoop-aws-3.3.2.jar,/opt/airflow/jars/aws-java-sdk-bundle-1.12.375.jar,/opt/airflow/jars/hadoop-common-3.3.2.jar,/opt/airflow/jars/hadoop-auth-3.3.2.jar") \
            .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
            .config("spark.hadoop.fs.s3a.access.key", aws_access_key) \
            .config("spark.hadoop.fs.s3a.secret.key", aws_secret_key) \
            .config("spark.hadoop.fs.s3a.endpoint", f"s3.{aws_region}.amazonaws.com") \
            .getOrCreate()
        
        # Criar um DataFrame de exemplo
        data = [("Cerveja A", 5.0), ("Cerveja B", 6.5), ("Cerveja C", 4.2)]
        columns = ["Nome", "Preço"]
        df = spark.createDataFrame(data, columns)
        
        # Escrever o DataFrame no S3 como Parquet
        s3_path = f"s3a://{bronze_bucket}/teste_pyspark/output.parquet"
        df.write.mode("overwrite").parquet(s3_path)
        
        # Encerrar a sessão Spark
        spark.stop()
    except Exception as e:
        if 'spark' in locals():
            spark.stop()
        raise e

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
}

with DAG('pyspark_write_s3_dag',
         default_args=default_args,
         schedule_interval='@daily',
         catchup=False) as dag:

    write_to_s3_task = PythonOperator(
        task_id='write_to_s3',
        python_callable=write_to_s3
    )

    write_to_s3_task
