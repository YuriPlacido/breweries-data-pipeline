# dags/scripts/transform_silver.py

import os
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, current_date

def transform_to_silver(aws_access_key, aws_secret_key, aws_region):
    """
    Transforma dados brutos em dados curados no bucket S3 silver como Parquet, particionados por estado.
    """
    try:
        # Nome dos buckets
        bronze_bucket = os.getenv('BRONZE_BUCKET_NAME', 'breweries-data-pipeline-bronze-dev')
        silver_bucket = os.getenv('SILVER_BUCKET_NAME', 'breweries-data-pipeline-silver-dev')

        # Caminho dos dados brutos
        bronze_path = f"s3a://{bronze_bucket}/raw/breweries_*.json"

        # Caminho para dados curados
        silver_path = f"s3a://{silver_bucket}/curated/breweries_parquet"

        # Inicializar SparkSession
        spark = SparkSession.builder \
            .appName("TransformToSilver") \
            .config("spark.jars", "/opt/airflow/jars/hadoop-aws-3.3.2.jar,/opt/airflow/jars/aws-java-sdk-bundle-1.12.375.jar,/opt/airflow/jars/hadoop-common-3.3.2.jar,/opt/airflow/jars/hadoop-auth-3.3.2.jar") \
            .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
            .config("spark.hadoop.fs.s3a.access.key", aws_access_key) \
            .config("spark.hadoop.fs.s3a.secret.key", aws_secret_key) \
            .config("spark.hadoop.fs.s3a.endpoint", f"s3.{aws_region}.amazonaws.com") \
            .getOrCreate()

        # Ler dados brutos do S3
        df = spark.read.json(bronze_path)

        # Filtrar colunas que não estão completamente nulas
        non_null_columns = [c for c in df.columns if df.select(col(c)).filter(col(c).isNotNull()).count() > 0]
        filtered_df = df.select(*non_null_columns)

        # Adicionar a coluna 'last_update' com a data atual
        transformed_df = filtered_df.withColumn('last_update', current_date())

        # Escrever no S3 como Parquet, particionando por estado
        transformed_df.write.mode("overwrite").partitionBy("state").parquet(silver_path)

        # Encerrar sessão Spark
        spark.stop()

        print(f"Dados curados escritos em {silver_path}")

    except Exception as e:
        print(f"Erro ao transformar dados para a camada silver: {e}")
        raise
