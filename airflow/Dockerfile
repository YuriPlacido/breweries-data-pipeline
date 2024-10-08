FROM apache/airflow:2.5.0

# Switch para usuário root para instalar pacotes do sistema
USER root

# Instalar Java, wget e outras dependências
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Definir JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/
ENV PATH=$JAVA_HOME/bin:$PATH

# Criar diretório para JARs do Hadoop e AWS
RUN mkdir -p /opt/airflow/jars

# Baixar as dependências necessárias correspondentes à versão do Hadoop
RUN wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.2/hadoop-aws-3.3.2.jar -P /opt/airflow/jars/ && \
    wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.375/aws-java-sdk-bundle-1.12.375.jar -P /opt/airflow/jars/ && \
    wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/3.3.2/hadoop-common-3.3.2.jar -P /opt/airflow/jars/ && \
    wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-auth/3.3.2/hadoop-auth-3.3.2.jar -P /opt/airflow/jars/

# Copiar o arquivo requirements.txt para o contêiner
COPY requirements.txt /tmp/

# Voltar para o usuário airflow antes de instalar dependências Python
USER airflow

# Instalar dependências Python como usuário airflow
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Definir o comando padrão
CMD ["webserver"]