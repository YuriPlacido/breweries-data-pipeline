# variables.tf

variable "aws_region" {
  description = "Região AWS"
  default     = "sa-east-1"
}

variable "environment" {
  description = "Ambiente de Desenvolvimento"
  default     = "dev"
}

variable "project_name" {
  description = "Nome do projeto"
  default     = "breweries-data-pipeline"
}
