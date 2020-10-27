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
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
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
    availability_zone = var.azs[0]
    instance_type = "t2.micro"
    key_name = aws_key_pair.terraform-key.key_name
    vpc_security_group_ids = [aws_security_group.web.id]
    subnet_id = aws_subnet.az1-public.id
    associate_public_ip_address = true
    source_dest_check = false


    tags ={
        Name = "web_server${count.index}"

    }
}

resource "aws_eip" "web" {
    count = var.resource_count
    instance = aws_instance.web[count.index].id
    vpc = true
}