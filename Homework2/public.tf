/*
  Web Servers
*/
resource "aws_security_group" "web" {
    name = "vpc_web"
    description = "Allow incoming HTTP connections."

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = aws_vpc.default.id

    tags ={
        Name = "WebServerSG"
    }
}

resource "aws_instance" "web" {
    count = var.resource_count
    ami = data.aws_ami.ubuntu.id
    availability_zone = var.azs[count.index]
    instance_type = "t2.micro"
    key_name = aws_key_pair.terraform-key.key_name
    vpc_security_group_ids = [aws_security_group.web.id]
    subnet_id = aws_subnet.public-subnet[count.index].id
    associate_public_ip_address = true
    connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = aws_key_pair.terraform-key.key_name

  }
    tags ={
        Name = "web_server${count.index}"

    }
}