# modules/glue_crawler/main.tf

# Banco de dados no Glue Data Catalog
resource "aws_glue_catalog_database" "glue_database" {
  name = "${var.project_name}_db_${var.environment}"
}

# Glue Crawler
resource "aws_glue_crawler" "glue_crawler" {
  name         = "${var.project_name}-crawler-${var.environment}"
  role         = var.glue_role_arn
  database_name = aws_glue_catalog_database.glue_database.name

  s3_target {
    path = "s3://${var.gold_bucket_name}/"
  }

  configuration = jsonencode({
    Version       = 1.0,
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
    }
  })
}

# Outputs

output "glue_crawler_name"{
  value = aws_glue_crawler.glue_crawler.name
}
