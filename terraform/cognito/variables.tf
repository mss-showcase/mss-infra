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

# CloudFront domain name (from S3 file CLOUDFRONT_DOMAIN_NAME.txt)
variable "cloudfront_domain_name" {
  description = "CloudFront domain name for HTTPS callback/logout URLs"
  type        = string
}
