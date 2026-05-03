

############################
# S3 Bucket
############################
resource "aws_s3_bucket" "upload_bucket" {
  bucket = "my-upload-bucket-${random_id.suffix.hex}"
}

resource "random_id" "suffix" {
  byte_length = 4
}

############################
# DynamoDB Table
############################
resource "aws_dynamodb_table" "file_metadata" {
  name         = "file-metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "file_name"

  attribute {
    name = "file_name"
    type = "S"
  }
}

############################
# IAM Role for Lambda
############################
resource "aws_iam_role" "lambda_role" {
  name = "lambda_s3_dynamodb_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

############################
# IAM Policy
############################
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem"
        ],
        Resource = aws_dynamodb_table.file_metadata.arn
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "${aws_s3_bucket.upload_bucket.arn}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

############################
# Lambda Function
############################
resource "aws_lambda_function" "file_logger" {
  function_name = "file-upload-logger"
  role          = aws_iam_role.lambda_role.arn
  handler       = "function.lambda_handler"
  runtime       = "python3.10"

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.file_metadata.name
    }
  }
}

############################
# S3 Trigger Permission
############################
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_logger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_bucket.arn
}

############################
# S3 Event Notification
############################
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.upload_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.file_logger.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
