import boto3
from airflow.hooks.base import BaseHook

def test_s3_connection(conn_id='aws_default'):
    try:
        # Recuperar a conexão AWS do Airflow
        conn = BaseHook.get_connection(conn_id)
        aws_access_key = conn.login
        aws_secret_key = conn.password
        aws_region = conn.extra_dejson.get('region_name', 'sa-east-1')
        
        # Inicializar o cliente S3 do boto3
        s3_client = boto3.client(
            's3',
            aws_access_key_id=aws_access_key,
            aws_secret_access_key=aws_secret_key,
            region_name=aws_region
        )
        
        # Tentar listar os buckets S3
        response = s3_client.list_buckets()
        print("Conexão bem-sucedida. Buckets S3:")
        for bucket in response.get('Buckets', []):
            print(f" - {bucket['Name']}")
    except Exception as e:
        print(f"Falha na conexão: {e}")

if __name__ == "__main__":
    test_s3_connection()
