output "site_bucket_name" {
  description = "Name of the S3 bucket hosting the site"
  value       = aws_s3_bucket.site.bucket
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.cdn.domain_name
}
