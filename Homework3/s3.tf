# S3 bucket & policy

resource "aws_s3_bucket" "bucket" {
  bucket = "chagit-access-logs"
  tags   = {Name = "s3-nginx-access-logs" }
}

resource "aws_s3_bucket_policy" "b_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.template_file.policy_s3_bucket.rendered
}
