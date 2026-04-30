terraform {
  required_version = ">= 1.0"
}

# AWS S3 public bucket (VERY commonly detected)
resource "aws_s3_bucket" "public_bucket" {
  bucket = "wiz-test-public-bucket-12345"
}

resource "aws_s3_bucket_public_access_block" "bad" {
  bucket = aws_s3_bucket.public_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
