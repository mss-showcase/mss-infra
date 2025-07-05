resource "aws_cognito_user_pool" "main" {
  name = "mss-user-pool"

  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    mutable             = true
  }

  schema {
    attribute_data_type = "String"
    name                = "profile_image_url"
    required            = false
    mutable             = true
  }

  admin_create_user_config {
    allow_admin_create_user_only = false # allow self sign-up
  }

  # Allow users to sign up and sign in with any OAuth provider (to be attached below)
  # The actual provider configs are attached to the user pool client below
}

resource "aws_cognito_user_pool_client" "main" {
  name         = "mss-user-pool-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH"
  ]

  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client = true


  # Use CloudFront HTTPS domain for callback/logout URLs
  callback_urls = [
    "https://${var.cloudfront_domain_name}/callback"
  ]
  logout_urls = [
    "https://${var.cloudfront_domain_name}/logout"
  ]

  supported_identity_providers = ["COGNITO", aws_cognito_identity_provider.google.provider_name]

  depends_on = [aws_cognito_identity_provider.google]
}

# Google identity provider
resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "Google"
  provider_type = "Google"
  provider_details = {
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
    authorize_scopes = "openid email profile"
  }
  attribute_mapping = {
    email = "email"
    name  = "name"
  }
}

# Outputs for debugging and other services
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
