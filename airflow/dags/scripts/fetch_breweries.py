# airflow/dags/scripts/fetch_breweries.py

import requests
import os
import pandas as pd
import boto3
from datetime import datetime
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

def fetch_breweries(aws_access_key, aws_secret_key, aws_region):
    """
    Extrai dados da API Open Brewery DB e salva no bucket S3 bronze como JSON.
    """
    try:
        # Endpoint da API
        api_url = "https://api.openbrewerydb.org/breweries"
        response = requests.get(api_url)
        response.raise_for_status()
        breweries_data = response.json()

        # Converter os dados para um DataFrame Pandas
        df = pd.DataFrame(breweries_data)

        # Nome do bucket bronze a partir de variáveis de ambiente ou default
        bronze_bucket = os.getenv('BRONZE_BUCKET_NAME', 'breweries-data-pipeline-bronze-dev')

        # Definir o nome do arquivo com data no formato YYYY-MM-DD
        file_name = f"breweries_{datetime.now().strftime('%Y-%m-%d')}.json"

        # Caminho completo no S3
        bronze_path = f"raw/{file_name}"

        # Inicializar o cliente S3 com Boto3
        s3_client = boto3.client(
            's3',
            aws_access_key_id=aws_access_key,
            aws_secret_access_key=aws_secret_key,
            region_name=aws_region
        )

        # Converter o DataFrame para JSON no formato desejado
        json_buffer = df.to_json(orient='records', lines=True)

        # Escrever o JSON diretamente no S3
        s3_client.put_object(Bucket=bronze_bucket, Key=bronze_path, Body=json_buffer)

        print(f"Dados brutos escritos em s3://{bronze_bucket}/{bronze_path}")

    except requests.exceptions.RequestException as req_err:
        print(f"Erro ao buscar dados da API: {req_err}")
        raise

    except (NoCredentialsError, PartialCredentialsError) as cred_err:
        print(f"Erro de credenciais AWS: {cred_err}")
        raise

    except Exception as e:
        print(f"Erro ao buscar dados da API ou escrever no S3: {e}")
        raise
