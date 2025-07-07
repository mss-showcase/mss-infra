# CloudFront domain name for CORS
variable "cloudfront_domain_name" {
  description = "CloudFront domain name for CORS"
  type        = string
}
# ARN for the sentiment articles DynamoDB table
variable "dynamodb_sentiment_articles_table_arn" {
  description = "ARN of the DynamoDB table for sentiment articles"
  type        = string
}
variable "build_data_bucket" {
  description = "S3 bucket for Lambda artifact"
  type        = string
}

variable "shared_data_bucket" {
  description = "S3 bucket for app data (source for Lambda trigger and read access)"
  type        = string
}

variable "mss_backend_lambda_name" {
  description = "Name of the backend Lambda"
  type        = string
}

variable "mss_backend_lambda_s3_key" {
  description = "S3 key for the backend Lambda artifact"
  type        = string
}

variable "ticks_table" {
  description = "DynamoDB table for ticks"
  type        = string
}

variable "fundamentals_table" {
  description = "DynamoDB table for fundamentals"
  type        = string
}

variable "ticks_table_arn" {
  description = "DynamoDB table ARN for ticks (optional, if table is managed elsewhere)"
  type        = string
  default     = null
}

variable "fundamentals_table_arn" {
  description = "DynamoDB table ARN for fundamentals (optional, if table is managed elsewhere)"
  type        = string
  default     = null
}

variable "dynamodb_sentiment_articles_table" {
  description = "DynamoDB table for sentiment articles"
  type        = string
}

variable "cognito_pool_id" {
  description = "The Cognito User Pool ID"
  type        = string
}

variable "cognito_pool_arn" {
  description = "The ARN of the Cognito User Pool for user management permissions."
  type        = string
}

variable "webhosting_website_url" {
  description = "S3 static website endpoint for shared webhosting bucket."
  type        = string
}