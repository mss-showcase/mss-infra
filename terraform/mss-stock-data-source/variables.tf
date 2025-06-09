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

variable "data_bucket" {
  description = "value of the S3 bucket name to store data"
  type        = string
}

variable "artifact_key" {
  description = "value of the S3 key for the Lambda function artifact"
  type        = string
}

variable "cloudfront_key_group_id" {
  description = "value of the CloudFront key group ID for signed URLs"
  type        = string
}

variable "lambda_name" {
  description = "value of the Lambda function name"
  type        = string
  default     = "mss-stock-data-source-lambda"
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

