output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.main.id
}

output "google_identity_provider_name" {
  description = "Name of the Google Identity Provider"
  value       = aws_cognito_identity_provider.google.provider_name
}
