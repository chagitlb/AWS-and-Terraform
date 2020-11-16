# S3 bucket & policy

resource "aws_s3_bucket" "terraform_state" {
  bucket = "chagit-state"

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

  tags = { Name = "s3-terraform-state" }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "chagit-access-logs"
  tags   = {Name = "s3-nginx-access-logs" }
}

resource "aws_s3_bucket_policy" "b_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.template_file.policy_s3_bucket.rendered
}
