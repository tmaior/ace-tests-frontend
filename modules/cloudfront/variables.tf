variable "origin_domain_name" {
  description = "Origin domain for CloudFront (typically the S3 bucket regional domain)"
  type        = string
}

variable "origin_bucket_arn" {
  description = "S3 bucket ARN for policy"
  type        = string
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}
