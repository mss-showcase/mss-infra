output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = local.user_pool_id
}

output "user_pool_client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = local.user_pool_client_id
}

output "google_provider_name" {
  description = "Name of the Google identity provider"
  value       = "Google"
}
