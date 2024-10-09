# Breweries Data Pipeline - Medallion Architecture

## Descrição

Este projeto implementa um pipeline de dados usando a API pública **Open Brewery DB** para coletar dados de cervejarias, transformá-los e persistir em um **Data Lake** na **AWS** usando a arquitetura de **Medalhão (Bronze, Silver, Gold)**. A orquestração do pipeline é feita utilizando o **Apache Airflow**.

## Arquitetura

O pipeline segue a **Medallion Architecture** com três camadas de dados:

- **Bronze Layer**: Os dados são coletados da API e armazenados em seu formato bruto (JSON) no S3.
- **Silver Layer**: Os dados brutos são transformados, colunas nulas são removidas e dados são convertidos em formato **Parquet**. Os dados são particionados por estado e armazenados no S3.
- **Gold Layer**: Um agregado dos dados é criado na camada de **Gold**, que contém o número de cervejarias por tipo e localização.

## Fluxo do Pipeline

1. **Bronze Layer**:
   - Consumo dos dados da API **Open Brewery DB**.
   - Armazenamento dos dados brutos no **S3** na camada **Bronze**.
   
2. **Silver Layer**:
   - Transformação dos dados para remover colunas nulas.
   - Criação de uma coluna de **última atualização** (`last_update`) com a data da execução.
   - Conversão para **Parquet** e armazenamento no **S3** na camada **Silver**, particionando por estado.

3. **Gold Layer**:
   - Criação de uma agregação que conta o número de cervejarias por tipo e localização.
   - Armazenamento dos dados agregados na camada **Gold** no **S3**.

4. **Monitoramento com AWS Glue**:
   - Um **Lambda** é acionado automaticamente sempre que novos dados são carregados na camada **Gold**.
   - O Lambda inicia o **AWS Glue Crawler** para atualizar os metadados.

## Configuração do Projeto

### Pré-requisitos

- **AWS Account** configurada com permissões para S3, Lambda, Glue, IAM, e o uso do Terraform.
- **Docker** e **Docker Compose** instalados.
- **Terraform** configurado no ambiente local.

### Instalação e Setup

1. **Clone o repositório:**

```bash
git clone https://github.com/YuriPlacido/breweries-data-pipeline.git
cd breweries-data-pipeline
```

2. **Configuração do Terraform:**

Navegue até o diretório terraform/ e execute os seguintes comandos:

```bash
terraform init
terraform plan
terraform apply
```

Isso criará buckets S3 e a função Lambda com o trigger para iniciar o Glue Crawler quando novos dados forem armazenados na camada Gold.

3. **Configuração do Airflow com Docker:**

Suba o ambiente do Airflow com Docker Compose:

```bash
docker-compose up -d
```

Acesse o Airflow em http://localhost:8080/ (usuário: airflow, senha: airflow).

4. **Execute o pipeline:**

No Airflow, ative e execute a DAG breweries_medallion_dag para rodar o pipeline completo.

**Estrutura de Pastas**

```bash
.
├── airflow
│   ├── dags
│   │   ├── scripts
│   │   │   ├── __init__.py
│   │   │   ├── aggregate_gold.py
│   │   │   ├── fetch_breweries.py
│   │   │   ├── transform_silver.py
│   │   ├── breweries_medallion_dag.py
│   ├── Dockerfile
│   ├── requirements.txt
├── aws_credentials
├── terraform
│   ├── modules
│   │   ├── glue_crawler
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   ├── iam_role
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   ├── iam_user
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   ├── lambda
│   │   │   ├── lambda_function.zip
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   ├── s3
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
├── docker-compose.yml
└── README.md
```

**Arquivos Principais**

- <b>Airflow DAG:</b> dags/breweries_medallion_dag.py
    - Define o fluxo do pipeline que consome, transforma e agrega os dados das cervejarias.

- <b>Fetch Breweries:</b> dags/scripts/fetch_breweries.py
    - Consome a API e armazena os dados brutos no S3.

- <b>Transform to Silver:</b> dags/scripts/transform_silver.py
    - Remove colunas nulas e transforma os dados para o formato Parquet.

- <b>Aggregate Gold:</b> dags/scripts/aggregate_gold.py
    - Gera um agregado dos dados por tipo de cervejaria e estado.

- <b>Terraform:</b> terraform/
    - Scripts de infraestrutura como código para criação de recursos AWS (buckets, Lambda, Glue Crawler, etc.).


