# modules/lambda/main.tf

# Função Lambda
resource "aws_lambda_function" "start_glue_crawler" {
  function_name = "${var.project_name}-start-glue-crawler-${var.environment}"
  role          = var.lambda_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  filename         = "${path.module}/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
}

# Configurar o trigger do S3
resource "aws_s3_bucket_notification" "gold_bucket_notification" {
  bucket = var.gold_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.start_glue_crawler.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke_lambda]
}

# Permissão para o S3 invocar a função Lambda
resource "aws_lambda_permission" "allow_s3_invoke_lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_glue_crawler.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.gold_bucket_name}"
}
