
/*
  Web Servers
*/
terraform {
  required_version = ">= 0.13"
}

resource "aws_instance" "ec2" {
  count                  = length(var.subnets)
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_groups
  subnet_id              = var.subnets[count.index]
  tags                   = { Name = "${var.name}-${count.index}" }
}