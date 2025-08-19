variable "site_bucket_name" {
  description = "S3 bucket name for the static site"
  type        = string
}

variable "enabled_logging" {
  description = "Enable S3 access logging"
  type        = bool
  default     = false
}
