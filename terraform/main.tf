provider "aws" {
  region = var.region
}

module "s3_site" {
  source = "../modules/s3_site"

  site_bucket_name = var.site_bucket_name
  enabled_logging  = var.enabled_logging
}

module "cloudfront" {
  source = "../modules/cloudfront"

  origin_domain_name    = module.s3_site.bucket_regional_domain_name
  origin_bucket_arn     = module.s3_site.arn
  price_class           = var.price_class
}

output "site_bucket_name" {
  value = module.s3_site.bucket
}

output "cloudfront_domain_name" {
  value = module.cloudfront.domain_name
}
