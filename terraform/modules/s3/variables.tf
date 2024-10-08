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
