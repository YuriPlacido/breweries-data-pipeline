# dags/scripts/aggregate_gold.py

import os
from pyspark.sql import SparkSession

def aggregate_gold(aws_access_key, aws_secret_key, aws_region):
    """
    Cria uma visão agregada com a quantidade de cervejarias por tipo e estado no bucket S3 gold como Parquet.
    """
    try:
        # Nome dos buckets
        silver_bucket = os.getenv('SILVER_BUCKET_NAME', 'breweries-data-pipeline-silver-dev')
        gold_bucket = os.getenv('GOLD_BUCKET_NAME', 'breweries-data-pipeline-gold-dev')

        # Caminho dos dados curados
        silver_path = f"s3a://{silver_bucket}/curated/breweries_parquet"

        # Caminho para dados agregados
        gold_path = f"s3a://{gold_bucket}/aggregated/breweries_aggregated.parquet"

        # Inicializar SparkSession
        spark = SparkSession.builder \
            .appName("AggregateToGold") \
            .config("spark.jars", "/opt/airflow/jars/hadoop-aws-3.3.2.jar,/opt/airflow/jars/aws-java-sdk-bundle-1.12.375.jar,/opt/airflow/jars/hadoop-common-3.3.2.jar,/opt/airflow/jars/hadoop-auth-3.3.2.jar") \
            .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
            .config("spark.hadoop.fs.s3a.access.key", aws_access_key) \
            .config("spark.hadoop.fs.s3a.secret.key", aws_secret_key) \
            .config("spark.hadoop.fs.s3a.endpoint", f"s3.{aws_region}.amazonaws.com") \
            .getOrCreate()

        # Ler dados curados do S3
        df = spark.read.parquet(silver_path)

        # Criar visão agregada: quantidade de cervejarias por tipo e estado
        aggregated_df = df.groupBy("brewery_type", "state") \
                         .count() \
                         .withColumnRenamed("count", "brewery_count")

        # Escrever no S3 como Parquet
        aggregated_df.write.mode("overwrite").parquet(gold_path)

        # Encerrar sessão Spark
        spark.stop()

        print(f"Dados agregados escritos em {gold_path}")

    except Exception as e:
        print(f"Erro ao agregar dados para a camada gold: {e}")
        raise
