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
