# modules/iam_role/main.tf

# IAM Role para o AWS Glue
resource "aws_iam_role" "glue_role" {
  name = "${var.project_name}-glue-role-${var.environment}"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  })
}

# Política gerenciada do AWS Glue
resource "aws_iam_role_policy_attachment" "glue_service_policy_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Política personalizada para acesso ao S3
resource "aws_iam_policy" "glue_s3_policy" {
  name   = "${var.project_name}-glue-s3-gold-policy-${var.environment}"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "${var.gold_bucket_arn}",
        "${var.gold_bucket_arn}/*"
      ]
    }]
  })
}

# Anexar a política à role do Glue
resource "aws_iam_role_policy_attachment" "glue_s3_policy_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_policy.arn
}

# IAM Role para o AWS Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  })
}

# Política básica para o Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Política para o Lambda iniciar o Glue Crawler
resource "aws_iam_policy" "lambda_glue_policy" {
  name   = "${var.project_name}-lambda-glue-policy-${var.environment}"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": [
        "glue:StartCrawler"
      ],
      "Resource": "*"
    }]
  })
}

# Anexar a política à role do Lambda
resource "aws_iam_role_policy_attachment" "lambda_glue_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_glue_policy.arn
}

# Outputs

output "glue_role_arn" {
  value = aws_iam_role.glue_role.arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}
