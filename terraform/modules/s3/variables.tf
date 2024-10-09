# modules/s3/variables.tf

variable "aws_region" {
  description = "Região da AWS para implantar os recursos"
  default     = "sa-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente de implantação"
  type        = string
}

variable "iam_role_arn" {
  description = "ARN da Role IAM que terá acesso aos buckets"
  type        = string
}

variable "lambda_arn" {
  description = "ARN da função Lambda para ser disparada pelo S3"
  type        = string
}

variable "lambda_name" {
  description = "Nome da função Lambda"
  type        = string
}