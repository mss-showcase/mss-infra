# Name of the S3 webhosting bucket (from GitHub org variable WEBHOSTING_BUCKET)
variable "webhosting_bucket" {
  description = "Name of the S3 bucket used for webhosting (no protocol, just the bucket name)"
  type        = string
}

# AWS region (from GitHub org variable AWS_REGION)
variable "aws_region" {
  description = "AWS region for constructing URLs"
  type        = string
}
