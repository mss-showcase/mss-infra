variable "aws_region" {
  description = "value of the AWS region to deploy resources in"
  type        = string
  default     = "eu-north-1"
}

variable "lambda_version" {
  description = "value of the Lambda function version to use - readed from the package.json file"
  type        = string
  default     = "1.0.0"
}

variable "artifact_key" {
  description = "value of the S3 key for the Lambda function artifact"
  type        = string
}

variable "lambda_name" {
  description = "value of the Lambda function name"
  type        = string
  default     = "mss-stock-data-source-lambda"
}

variable "run_mode_ticks" {
  description = "Ticks Run mode for the Stock data source Lambda function: it can be 'ticks' or 'funcdamentals'"
  type        = string
  default     = "ticks"
}

variable "run_mode_fundamentals" {
  description = "Ticks Run mode for the Stock data source Lambda function: it can be 'ticks' or 'fundamentals'"
  type        = string
  default     = "fundamentals"
}

variable "alphavantage_api_key" {
  description = "value of the Alpha Vantage API key"
  type        = string
}

variable "build_data_bucket" {
  description = "S3 bucket for build artifacts"
  type        = string
}

variable "app_data_bucket" {
  description = "S3 bucket for application data (CloudFront origin)"
  type        = string
}

variable "fundamentals_lambda_name" {
  description = "Name of the fundamentals Lambda function"
  type        = string
  default     = "mss-fundamentals-lambda"
}

variable "fundamentals_artifact_key" {
  description = "S3 key for the fundamentals Lambda artifact"
  type        = string
}

