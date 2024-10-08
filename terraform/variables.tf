# variables.tf

variable "aws_region" {
  description = "Região da AWS para implantar os recursos"
  default     = "sa-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  default     = "breweries-data-pipeline"
}

variable "environment" {
  description = "Ambiente de implantação"
  default     = "dev"
}

variable "iam_role_arn" {
  description = "ARN da Role IAM que terá acesso aos buckets S3"
  type        = string
}