variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tf_state_bucket" {
  description = "S3 bucket name for Terraform state backend (must already exist)"
  type        = string
}

variable "tf_lock_table" {
  description = "DynamoDB table name for Terraform state locking (must already exist)"
  type        = string
}

variable "site_bucket_name" {
  description = "S3 bucket name to host the static site (must be globally unique)"
  type        = string
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "enabled_logging" {
  description = "Enable S3 access logging for the site bucket"
  type        = bool
  default     = false
}
