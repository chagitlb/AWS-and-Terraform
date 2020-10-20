##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {}
variable "region" {
  default = "us-east-1"
}
variable "AmiLinux" {
  type = "map"
  default = {
    us-east-1 = "ami-b73b63a0" # Virginia
  }
  description = "have only added one region"
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  profile = "default"
  region     = "us-east-1"
}

##################################################################################
# DATA
##################################################################################

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


##################################################################################
# RESOURCES
##################################################################################

#This uses the default VPC.  It WILL NOT delete it on destroy.
resource "aws_default_vpc" "default" {

}

resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "s3-role"
  assume_role_policy = "${file("assumerolepolicy.json")}"
}
resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"
  policy      = "${file("policys3bucket.json")}"
}
resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  roles      = ["${aws_iam_role.ec2_s3_access_role.name}"]
  policy_arn = "${aws_iam_policy.policy.arn}"
}
resource "aws_iam_instance_profile" "test_profile" {
  name  = "test_profile"
  role = "${aws_iam_role.ec2_s3_access_role.name}"
}
resource "aws_security_group" "allow_ssh" {
  name        = "nginx_demo"
  description = "Allow ports for nginx test"
  vpc_id      = aws_default_vpc.default.id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  count = 2
  ami             = "${lookup(var.AmiLinux, var.region)}"
  instance_type   = "t2.medium"
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

    root_block_device {
    volume_size = "10"
    volume_type = "standard"
  }

  ebs_block_device {
    device_name = "/dev/sdm"
    volume_size = "10"
    volume_type = "gp2"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)

  }
  provisioner "file" {
    source      = "~/nginxScript"
    destination = "/tmp/nginxScript"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/nginxScript",
      "sudo /tmp/nginxScript",
    ]
  }
  tags ={
      name = "Terraform_test"
      purpose = "terraform_practice"
	}
}

##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
  value = aws_instance.nginx[0].public_dns
}
