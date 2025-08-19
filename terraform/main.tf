provider "aws" {
  region = var.region
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for site distribution"
}

resource "aws_s3_bucket" "site" {
  bucket = var.site_bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "keep-latest"
    enabled = true
    abort_incomplete_multipart_upload_days = 7
  }

  tags = {
    Name = "site-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "site_policy" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        }
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.site.arn,
          "${aws_s3_bucket.site.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN for static site"
  default_root_object = "index.html"

  origins {
    domain_name = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id   = "s3-site-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-site-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "site-cdn"
  }
}
