provider "aws" {
  region = var.aws_region
}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
data "template_file" "policy_s3_access" {
  template = file("policy_s3_access.json.tpl")

  vars = {
    s3_bucket_arn = aws_s3_bucket.bucket.arn
  }
}

data "template_file" "policy_s3_bucket" {
  template = file("policy_s3_bucket.json.tpl")

  vars = {
    s3_bucket_arn = aws_s3_bucket.bucket.arn
    role_arn      = aws_iam_role.ec2_s3_access_role.arn
  }
}

resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "s3-role"
  assume_role_policy = var.assume_role_policy_data
  tags               = { Name = "${var.env_name}-role-s3access" }
}

resource "aws_iam_policy" "policy" {
  name        = "policy-role-allow-s3"
  description = "Allow role to access s3 buckets"
  policy      = data.template_file.policy_s3_access.rendered
}

resource "aws_iam_policy_attachment" "poicy_attach" {
  name       = "policy-role-allow-s3-attachment"
  roles      = [aws_iam_role.ec2_s3_access_role.name]
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance-profile-1"
  role = aws_iam_role.ec2_s3_access_role.name
}
