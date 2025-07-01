variable "shared_data_bucket" {
  description = "The name of the shared S3 data bucket"
  type        = string
}

variable "build_data_bucket" {
  description = "S3 bucket for Lambda artifact"
  type        = string
}

variable "feed_reader_lambda_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "financial_sentiment_lambda_name" {
  description = "Name of the Financial Sentiment Lambda function"
  type        = string
}

variable "artifact_key" {
  description = "S3 key for Lambda artifact"
  type        = string
}

variable "articles_table" {
  description = "Name of the DynamoDB table for sentiment articles"
  type        = string
}

variable "feeds_table" {
  description = "Name of the DynamoDB table for sentiment feeds"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}