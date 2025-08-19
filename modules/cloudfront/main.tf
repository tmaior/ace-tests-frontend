resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for site distribution"
}

resource "aws_s3_bucket_policy" "site_policy" {
  bucket = var.origin_bucket_arn

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
          var.origin_bucket_arn,
          "${var.origin_bucket_arn}/*"
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
    domain_name = var.origin_domain_name
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

output "domain_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "distribution_id" {
  value = aws_cloudfront_distribution.cdn.id
}
