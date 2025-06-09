variable "cf_public_key_name" {
  type    = string
  default = "cf-public-key"
}

variable "cf_key_group_name" {
  type    = string
  default = "cf-key-group"
}

resource "aws_cloudfront_public_key" "cf_public_key" {
  name        = var.cf_public_key_name
  encoded_key = file("${path.module}/public.pem")
  comment     = "Public key for signed URLs"
}

resource "aws_cloudfront_key_group" "cf_key_group" {
  name = var.cf_key_group_name
  items = [
    aws_cloudfront_public_key.cf_public_key.id
  ]
}

resource "aws_s3_bucket" "build_artifacts" {
  bucket        = "aws-pet-project-build-artifacts"
  force_destroy = true
}

output "cloudfront_public_key_id" {
  value = aws_cloudfront_public_key.cf_public_key.id
}

output "cloudfront_key_group_id" {
  value = aws_cloudfront_key_group.cf_key_group.id
}