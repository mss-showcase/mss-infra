resource "aws_lambda_function" "mss_backend_lambda" {
  function_name = var.mss_backend_lambda_name
  s3_bucket     = var.build_data_bucket
  s3_key        = var.mss_backend_lambda_s3_key
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 30

  environment {
    variables = {
      TICKS_TABLE                       = var.ticks_table
      FUNDAMENTALS_TABLE                = var.fundamentals_table
      DYNAMODB_SENTIMENT_ARTICLES_TABLE = var.dynamodb_sentiment_articles_table
      COGNITO_POOL_ID                  = var.cognito_pool_id  
    }
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.mss_backend_lambda_name}-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "mss_backend_lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "mss_backend_lambda_policy" {
  name = "mss_backend_lambda_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        Resource = [
          var.ticks_table_arn,
          var.fundamentals_table_arn,
          var.dynamodb_sentiment_articles_table_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mss_backend_lambda_custom" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.mss_backend_lambda_policy.arn
}

resource "aws_apigatewayv2_api" "mss_backend_api" {
  name          = "mss-backend-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = [
      "http://localhost:5173",
      "https://${var.cloudfront_domain_name}"
    ]
    allow_methods  = ["GET", "OPTIONS"]
    allow_headers  = ["*"]
    expose_headers = ["*"]
    max_age        = 86400
  }
}

resource "aws_apigatewayv2_integration" "mss_backend_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.mss_backend_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.mss_backend_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "stocks_route" {
  api_id    = aws_apigatewayv2_api.mss_backend_api.id
  route_key = "GET /stocks"
  target    = "integrations/${aws_apigatewayv2_integration.mss_backend_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "ticks_route" {
  api_id    = aws_apigatewayv2_api.mss_backend_api.id
  route_key = "GET /ticks/{symbol}"
  target    = "integrations/${aws_apigatewayv2_integration.mss_backend_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "fundamentals_route" {
  api_id    = aws_apigatewayv2_api.mss_backend_api.id
  route_key = "GET /fundamentals/{symbol}"
  target    = "integrations/${aws_apigatewayv2_integration.mss_backend_lambda_integration.id}"
}

# New endpoints for analysis
resource "aws_apigatewayv2_route" "analysis_ta_stockmarkers_route" {
  api_id    = aws_apigatewayv2_api.mss_backend_api.id
  route_key = "GET /analysis/ta/stockmarkers"
  target    = "integrations/${aws_apigatewayv2_integration.mss_backend_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "analysis_ta_stockmarker_route" {
  api_id    = aws_apigatewayv2_api.mss_backend_api.id
  route_key = "GET /analysis/ta/stockmarker/{ticker}/{markerid}"
  target    = "integrations/${aws_apigatewayv2_integration.mss_backend_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "analysis_explanation_route" {
  api_id    = aws_apigatewayv2_api.mss_backend_api.id
  route_key = "GET /analysis/{ticker}/explanation"
  target    = "integrations/${aws_apigatewayv2_integration.mss_backend_lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "mss_backend_stage" {
  api_id      = aws_apigatewayv2_api.mss_backend_api.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }
}

resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mss_backend_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.mss_backend_api.execution_arn}/*/*"
}