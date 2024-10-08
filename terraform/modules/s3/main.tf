# modules/s3/main.tf

provider "aws" {
  region = var.aws_region
}

# Nome dos buckets
locals {
  bronze_bucket_name = "${var.project_name}-bronze-${var.environment}"
  silver_bucket_name = "${var.project_name}-silver-${var.environment}"
  gold_bucket_name   = "${var.project_name}-gold-${var.environment}"
}

# Definições de recursos usando locals

# Bucket S3 da Camada Bronze
resource "aws_s3_bucket" "bronze_bucket" {
  bucket = local.bronze_bucket_name

  tags = {
    Name        = local.bronze_bucket_name
    Environment = var.environment
    Project     = var.project_name
    Layer       = "bronze"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Bucket S3 da Camada Silver
resource "aws_s3_bucket" "silver_bucket" {
  bucket = local.silver_bucket_name

  tags = {
    Name        = local.silver_bucket_name
    Environment = var.environment
    Project     = var.project_name
    Layer       = "silver"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Bucket S3 da Camada Gold
resource "aws_s3_bucket" "gold_bucket" {
  bucket = local.gold_bucket_name

  tags = {
    Name        = local.gold_bucket_name
    Environment = var.environment
    Project     = var.project_name
    Layer       = "gold"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Definição da Política para o Bucket Bronze
data "aws_iam_policy_document" "bronze_bucket_policy" {
  statement {
    sid    = "AllowAirflowAccessBronze"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.iam_role_arn]
    }

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      aws_s3_bucket.bronze_bucket.arn,
      "${aws_s3_bucket.bronze_bucket.arn}/*"
    ]
  }
}

# Aplicando a Política ao Bucket Bronze
resource "aws_s3_bucket_policy" "bronze_bucket_policy" {
  bucket = aws_s3_bucket.bronze_bucket.id
  policy = data.aws_iam_policy_document.bronze_bucket_policy.json
}

# Definição da Política para o Bucket Silver
data "aws_iam_policy_document" "silver_bucket_policy" {
  statement {
    sid    = "AllowAirflowAccessSilver"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.iam_role_arn]
    }

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      aws_s3_bucket.silver_bucket.arn,
      "${aws_s3_bucket.silver_bucket.arn}/*"
    ]
  }
}

# Aplicando a Política ao Bucket Silver
resource "aws_s3_bucket_policy" "silver_bucket_policy" {
  bucket = aws_s3_bucket.silver_bucket.id
  policy = data.aws_iam_policy_document.silver_bucket_policy.json
}

# Definição da Política para o Bucket Gold
data "aws_iam_policy_document" "gold_bucket_policy" {
  statement {
    sid    = "AllowAirflowAccessGold"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.iam_role_arn]
    }

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      aws_s3_bucket.gold_bucket.arn,
      "${aws_s3_bucket.gold_bucket.arn}/*"
    ]
  }
}

# Aplicando a Política ao Bucket Gold
resource "aws_s3_bucket_policy" "gold_bucket_policy" {
  bucket = aws_s3_bucket.gold_bucket.id
  policy = data.aws_iam_policy_document.gold_bucket_policy.json
}

# Outputs
output "bronze_bucket_name" {
  value = aws_s3_bucket.bronze_bucket.bucket
}

output "silver_bucket_name" {
  value = aws_s3_bucket.silver_bucket.bucket
}

output "gold_bucket_name" {
  value = aws_s3_bucket.gold_bucket.bucket
}

output "bronze_bucket_policy" {
  description = "Política do Bucket Bronze"
  value       = aws_s3_bucket_policy.bronze_bucket_policy.policy
}

output "silver_bucket_policy" {
  description = "Política do Bucket Silver"
  value       = aws_s3_bucket_policy.silver_bucket_policy.policy
}

output "gold_bucket_policy" {
  description = "Política do Bucket Gold"
  value       = aws_s3_bucket_policy.gold_bucket_policy.policy
}
