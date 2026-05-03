module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.8.0"

  function_name = "file-upload-logger"
  handler       = "index.lambda_handler"
  runtime       = "python3.10"

  source_path = "../src/lambda-function1"

  create_role = false
  lambda_role = "arn:aws:iam::116036306648:role/lambda-role-exce"

  environment_variables = {
    TABLE_NAME = "file-metadata"
  }
}



resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = "file-upload-logger"
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::safron-116036306648-us-east-1-lambda-02"
}



resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.upload_bucket.id

  lambda_function {
    lambda_function_arn = "arn:aws:lambda:us-east-1:116036306648:function:file-upload-logger"
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
