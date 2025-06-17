variable "build_data_bucket" {
  description = "S3 bucket for Lambda artifact"
  type        = string
}

variable "shared_data_bucket" {
  description = "S3 bucket for app data (source for Lambda trigger and read access)"
  type        = string
}

variable "lambda_name" {
  description = "Lambda function name"
  type        = string
}

variable "s3_key" {
  description = "S3 key for Lambda artifact"
  type        = string
}

variable "files_table" {
  description = "DynamoDB table for files"
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

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

