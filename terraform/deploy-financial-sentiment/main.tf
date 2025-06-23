provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "sentiment_lambda_exec_role" {
  name = "sentiment-lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "sentiment_lambda_exec_inline_policy" {
  name = "sentiment-lambda-exec-policy"
  role = aws_iam_role.sentiment_lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:BatchWriteItem"
        ],
        Resource = [
          aws_dynamodb_table.articles_table.arn,
          aws_dynamodb_table.feeds_table.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::${var.build_data_bucket}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.shared_data_bucket}",
          "arn:aws:s3:::${var.shared_data_bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_lambda_function" "sentiment_lambda" {
  function_name = var.sentiment_lambda_name
  s3_bucket     = var.build_data_bucket
  s3_key        = var.artifact_key
  handler       = "handler.lambda_handler" # <--- handler.py, function: lambda_handler
  runtime       = "python3.11"
  role          = aws_iam_role.sentiment_lambda_exec_role.arn
  timeout       = 60
  environment {
    variables = {
      ARTICLES_TABLE = var.articles_table
      FEEDS_TABLE    = var.feeds_table
    }
  }
}

resource "aws_cloudwatch_event_rule" "twice_daily" {
  name                = "${var.sentiment_lambda_name}-twice-daily"
  schedule_expression = "cron(0 0,12 * * ? *)" # At 00:00 and 12:00 UTC every day
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.twice_daily.name
  target_id = "sentimentLambda"
  arn       = aws_lambda_function.sentiment_lambda.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sentiment_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.twice_daily.arn
}

resource "aws_dynamodb_table" "articles_table" {
  name         = var.articles_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}

resource "aws_dynamodb_table" "feeds_table" {
  name         = var.feeds_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}