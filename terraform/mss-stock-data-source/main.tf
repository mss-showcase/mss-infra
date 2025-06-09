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

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "stock_data_lambda" {
  function_name = var.lambda_name
  s3_bucket     = var.build_data_bucket
  s3_key        = var.artifact_key
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 60

  environment {
    variables = {
      ALPHAVANTAGE_API_KEY = var.alphavantage_api_key
      SHARED_DATA_BUCKET   = var.app_data_bucket
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
