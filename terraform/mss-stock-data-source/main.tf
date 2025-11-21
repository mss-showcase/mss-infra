# Set log group retention for both Lambda functions
resource "aws_cloudwatch_log_group" "stock_data_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.stock_data_lambda.function_name}"
  retention_in_days = 5
}

resource "aws_cloudwatch_log_group" "fundamentals_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.fundamentals_lambda.function_name}"
  retention_in_days = 5
}
resource "aws_iam_role" "lambda_exec_role" {
  name = "mss-lambda-exec-role"

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

resource "aws_iam_role_policy" "lambda_exec_inline_policy" {
  name = "lambda-exec-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.app_data_bucket}",
          "arn:aws:s3:::${var.app_data_bucket}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "stock_data_lambda" {
  function_name = var.lambda_name
  s3_bucket     = var.build_data_bucket
  s3_key        = var.artifact_key
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 60

  environment {
    variables = {
      ALPHAVANTAGE_API_KEY = var.alphavantage_api_key
      SHARED_DATA_BUCKET   = var.app_data_bucket
      RUN_MODE             = var.run_mode_ticks
    }
  }
}

resource "aws_cloudwatch_event_rule" "every_half_hour" {
  name                = "${var.lambda_name}-schedule"
  schedule_expression = "cron(0/30 9-17 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_half_hour.name
  target_id = "stockDataLambda"
  arn       = aws_lambda_function.stock_data_lambda.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stock_data_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_half_hour.arn
}

resource "aws_iam_role" "fundamentals_lambda_exec_role" {
  name = "mss-fundamentals-lambda-exec-role"

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

resource "aws_iam_role_policy" "fundamentals_lambda_exec_inline_policy" {
  name = "fundamentals-lambda-exec-policy"
  role = aws_iam_role.fundamentals_lambda_exec_role.id

  policy = aws_iam_role_policy.lambda_exec_inline_policy.policy
}

resource "aws_iam_role_policy_attachment" "fundamentals_lambda_logs" {
  role       = aws_iam_role.fundamentals_lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "fundamentals_lambda" {
  function_name = var.fundamentals_lambda_name
  s3_bucket     = var.build_data_bucket
  s3_key        = var.fundamentals_artifact_key
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  role          = aws_iam_role.fundamentals_lambda_exec_role.arn
  timeout       = 60

  environment {
    variables = {
      ALPHAVANTAGE_API_KEY = var.alphavantage_api_key
      SHARED_DATA_BUCKET   = var.app_data_bucket
      RUN_MODE             = var.run_mode_fundamentals
    }
  }
}

resource "aws_cloudwatch_event_rule" "fundamentals_monthly" {
  name                = "${var.fundamentals_lambda_name}-schedule"
  schedule_expression = "cron(0 0 1 * ? *)" # Once a month, 00:00 UTC on the 1st
}

resource "aws_cloudwatch_event_target" "fundamentals_lambda_target" {
  rule      = aws_cloudwatch_event_rule.fundamentals_monthly.name
  target_id = "fundamentalsLambda"
  arn       = aws_lambda_function.fundamentals_lambda.arn
}

resource "aws_lambda_permission" "fundamentals_allow_events" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fundamentals_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.fundamentals_monthly.arn
}
