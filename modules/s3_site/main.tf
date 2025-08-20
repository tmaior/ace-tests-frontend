resource "aws_s3_bucket" "this" {
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
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket" {
  value = aws_s3_bucket.this.bucket
}

output "arn" {
  value = aws_s3_bucket.this.arn
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.this.bucket_regional_domain_name
}
