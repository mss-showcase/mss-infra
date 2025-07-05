variable "cf_public_key_name" {
  type    = string
  default = "cf-public-key"
}

variable "cf_key_group_name" {
  type    = string
  default = "cf-key-group"
}

variable "build_data_bucket" {
  description = "S3 bucket for build artifacts"
  type        = string
}