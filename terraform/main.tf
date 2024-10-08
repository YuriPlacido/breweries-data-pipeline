# main.tf

# Chamar o módulo s3
module "s3_buckets" {
  source        = "../modules/s3"
  
  project_name  = var.project_name
  environment   = var.environment
  aws_region    = var.aws_region
  iam_role_arn  = var.iam_role_arn
}

# Chamar o módulo iam_role
module "iam_role" {
  source = "./modules/iam_role"

  project_name    = var.project_name
  environment     = var.environment
  gold_bucket_arn = "arn:aws:s3:::${module.s3.gold_bucket_name}"
}

# Chamar o módulo iam_user
module "iam_user" {
  source = "./modules/iam_user"

  project_name       = var.project_name
  environment        = var.environment
  bronze_bucket_arn  = "arn:aws:s3:::${module.s3.bronze_bucket_name}"
  silver_bucket_arn  = "arn:aws:s3:::${module.s3.silver_bucket_name}"
  gold_bucket_arn    = "arn:aws:s3:::${module.s3.gold_bucket_name}"
}

# Chamar o módulo glue_crawler
module "glue_crawler" {
  source = "./modules/glue_crawler"

  project_name    = var.project_name
  environment     = var.environment
  glue_role_arn   = module.iam_role.glue_role_arn
  gold_bucket_name = module.s3.gold_bucket_name
}

# Chamar o módulo lambda
module "lambda" {
  source = "./modules/lambda"

  project_name      = var.project_name
  environment       = var.environment
  lambda_role_arn   = module.iam_role.lambda_role_arn
  glue_crawler_name = module.glue_crawler.glue_crawler_name
  gold_bucket_name  = module.s3.gold_bucket_name
}