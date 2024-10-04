# modules/iam_user/variables.tf

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente de implantação"
  type        = string
}

variable "bronze_bucket_arn" {
  description = "ARN do bucket S3 da camada bronze"
  type        = string
}

variable "silver_bucket_arn" {
  description = "ARN do bucket S3 da camada prata"
  type        = string
}

variable "gold_bucket_arn" {
  description = "ARN do bucket S3 da camada ouro"
  type        = string
}