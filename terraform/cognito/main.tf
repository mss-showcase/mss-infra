



# Data sources for existing resources
data "aws_cognito_user_pool" "main" {
  count        = var.cognito_user_pool_id != "" ? 1 : 0
  user_pool_id = var.cognito_user_pool_id
}

data "aws_cognito_user_pool_client" "main" {
  count        = var.cognito_user_pool_id != "" ? 1 : 0
  user_pool_id = var.cognito_user_pool_id
  client_id    = var.cognito_user_pool_client_id
}

# Resources for new resources

resource "aws_cognito_user_pool" "main" {
  count                    = var.cognito_user_pool_id == "" ? 1 : 0
  name                     = "mss-user-pool"
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
}


resource "aws_cognito_user_pool_client" "main" {
  count           = var.cognito_user_pool_id == "" ? 1 : 0
  name            = "mss-user-pool-client"
  user_pool_id    = aws_cognito_user_pool.main[0].id
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
  callback_urls = [
    "https://${var.cloudfront_domain_name}/callback"
  ]
  logout_urls = [
    "https://${var.cloudfront_domain_name}/logout"
  ]
  supported_identity_providers = ["COGNITO", "Google"]
}


# Google identity provider (only create if not using existing pool/client)
resource "aws_cognito_identity_provider" "google" {
  count         = var.cognito_user_pool_id == "" ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.main[0].id
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


# Locals to select the correct IDs
locals {
  user_pool_id        = var.cognito_user_pool_id != "" ? data.aws_cognito_user_pool.main[0].id : aws_cognito_user_pool.main[0].id
  user_pool_client_id = var.cognito_user_pool_id != "" ? data.aws_cognito_user_pool_client.main[0].id : aws_cognito_user_pool_client.main[0].id
}