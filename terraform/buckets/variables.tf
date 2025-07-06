variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "shared_data_bucket" {
  description = "The name of the shared data S3 bucket"
  type        = string
}

variable "shared_build_data_bucket" {
  type    = string
  default = "mss-s3bucket-shared-build-data"
}

variable "webhosting_bucket" {
  description = "The name of the webhosting S3 bucket"
  type        = string
}
