# modules/iam_user/main.tf

# Usuário IAM para o Airflow
resource "aws_iam_user" "airflow_user" {
  name = "${var.project_name}-airflow-user-${var.environment}"
}

# Política para o usuário Airflow
resource "aws_iam_user_policy" "airflow_user_policy" {
  name = "${var.project_name}-airflow-user-policy-${var.environment}"
  user = aws_iam_user.airflow_user.name
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "${var.bronze_bucket_arn}",
        "${var.bronze_bucket_arn}/*",
        "${var.silver_bucket_arn}",
        "${var.silver_bucket_arn}/*",
        "${var.gold_bucket_arn}",
        "${var.gold_bucket_arn}/*"
      ]
    }]
  })
}

# Chave de acesso para o usuário Airflow
resource "aws_iam_access_key" "airflow_access_key" {
  user = aws_iam_user.airflow_user.name
}
