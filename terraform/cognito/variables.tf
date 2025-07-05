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

# Google OAuth client ID (from GitHub org secret GOOGLE_CLIENT_ID)
variable "google_client_id" {
  description = "Google OAuth client ID for Cognito identity provider"
  type        = string
}

# Google OAuth client secret (from GitHub org secret GOOGLE_CLIENT_SECRET)
variable "google_client_secret" {
  description = "Google OAuth client secret for Cognito identity provider"
  type        = string
  sensitive   = true
}
