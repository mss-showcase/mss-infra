resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for app data bucket"
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = "${var.app_data_bucket}.s3.${var.aws_region}.amazonaws.com"
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    trusted_key_groups = [var.cloudfront_key_group_id]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "mss showcase project"
  }
}

resource "aws_s3_bucket_policy" "app_data_policy" {
  bucket = var.app_data_bucket
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        },
        Action   = "s3:GetObject",
        Resource = "arn:aws:s3:::${var.app_data_bucket}/*"
      }
    ]
  })
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.cf_distribution.id
}
