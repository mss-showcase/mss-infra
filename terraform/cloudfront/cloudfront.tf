# Response headers policy for COOP on callback/logout
resource "aws_cloudfront_response_headers_policy" "coop_unsafe_none" {
  name = "coop-unsafe-none"

  custom_headers_config {
    items {
      header   = "Cross-Origin-Opener-Policy"
      value    = "unsafe-none"
      override = true
    }
  }
}
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for webhosting bucket"
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  ordered_cache_behavior {
    path_pattern               = "/callback*"
    target_origin_id           = "s3-origin"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    response_headers_policy_id = aws_cloudfront_response_headers_policy.coop_unsafe_none.id
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

  ordered_cache_behavior {
    path_pattern               = "/logout/callback*"
    target_origin_id           = "s3-origin"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    response_headers_policy_id = aws_cloudfront_response_headers_policy.coop_unsafe_none.id
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
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = "${var.webhosting_bucket}.s3.${var.aws_region}.amazonaws.com"
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

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

  # Custom error page for SPA routing
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
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
    Name = "mss-showcase-frontend"
  }
}

# we need to create a combined policy for public read access (s3 static webhosting) and CloudFront OAI access 
# # this is to allow public read access for development purposes, it can be removed when CloudFront is set up or when the development is complete

resource "aws_s3_bucket_policy" "webhosting_policy" {
  bucket = var.webhosting_bucket
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "arn:aws:s3:::${var.webhosting_bucket}/*"
      },
      {
        Sid    = "AllowCloudFrontOAI"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        }
        Action   = ["s3:GetObject"]
        Resource = "arn:aws:s3:::${var.webhosting_bucket}/*"
      }
    ]
  })
}