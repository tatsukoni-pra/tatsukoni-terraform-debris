resource "aws_s3_bucket" "container_scan_demo" {
  bucket = "tatsukoni-pra-container-scan-demo"

  tags = {
    Name = "tatsukoni-pra-container-scan-demo"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "container_scan_demo" {
  bucket = aws_s3_bucket.container_scan_demo.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "container_scan_demo" {
  bucket = aws_s3_bucket.container_scan_demo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "container_scan_demo" {
  bucket      = aws_s3_bucket.container_scan_demo.id
  eventbridge = true
}
