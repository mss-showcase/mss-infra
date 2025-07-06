output "coop_unsafe_none_response_headers_policy_id" {
  value       = aws_cloudfront_response_headers_policy.coop_unsafe_none.id
  description = "ID of the CloudFront Response Headers Policy for COOP unsafe-none."
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cf_distribution.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cf_distribution.domain_name
}
