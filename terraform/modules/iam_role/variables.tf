# modules/iam_role/variables.tf

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente de implantação"
  type        = string
}

variable "gold_bucket_arn" {
  description = "ARN do bucket S3 da camada ouro"
  type        = string
}
