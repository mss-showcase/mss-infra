# Set log group retention for Lambda
resource "aws_cloudwatch_log_group" "stock_data_to_dynamo_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.stock_data_to_dynamo.function_name}"
  retention_in_days = 5
}
# Add your DynamoDB tables here if not already managed elsewhere

# The ttl attribute should be a Number (UNIX epoch time in seconds when the item should expire).
# Your Lambda should set the ttl attribute on items you want to expire.
# DynamoDB will automatically delete expired items.

resource "aws_dynamodb_table" "m7_imported_files" {
  name         = var.files_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "file_name"

  attribute {
    name = "file_name"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}

resource "aws_dynamodb_table" "m7_ticks" {
  name         = var.ticks_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "symbol"
  range_key    = "timestamp"

  attribute {
    name = "symbol"
    type = "S"
  }
  attribute {
    name = "timestamp"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}

resource "aws_dynamodb_table" "m7_fundamentals" {
  name         = var.fundamentals_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "symbol"
  range_key    = "as_of"

  attribute {
    name = "symbol"
    type = "S"
  }

  attribute {
    name = "as_of"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name = "m7_lambda_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          aws_dynamodb_table.m7_imported_files.arn,
          aws_dynamodb_table.m7_ticks.arn,
          aws_dynamodb_table.m7_fundamentals.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::${var.shared_data_bucket}/magnificent7-*.json.gz"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "stock_data_to_dynamo" {
  function_name = var.lambda_name
  s3_bucket     = var.build_data_bucket
  s3_key        = var.s3_key
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 60

  environment {
    variables = {
      FILES_TABLE        = var.files_table
      TICKS_TABLE        = var.ticks_table
      FUNDAMENTALS_TABLE = var.fundamentals_table
    }
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.lambda_name}-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_custom" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stock_data_to_dynamo.function_name
  principal     = "s3.amazonaws.com"
  # You should specify the source ARN of the S3 bucket or event
}

resource "aws_s3_bucket_notification" "trigger_lambda" {
  bucket = var.shared_data_bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.stock_data_to_dynamo.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "magnificent7-"
    filter_suffix       = ".json.gz"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

