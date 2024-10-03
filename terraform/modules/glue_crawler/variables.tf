# modules/glue_crawler/variables.tf

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente de implantação"
  type        = string
}

variable "glue_role_arn" {
  description = "ARN da IAM Role para o Glue"
  type        = string
}

variable "gold_bucket_name" {
  description = "Nome do bucket S3 da camada ouro"
  type        = string
}
