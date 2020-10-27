/*
  Database Servers
*/
resource "aws_security_group" "db" {
    name = "vpc_db"
    description = "Allow incoming database connections."

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = [var.vpc_cidr]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = aws_vpc.default.id

    tags ={
        Name = "DBServerSG"
    }
}

resource "aws_instance" "db" {
    count = var.resource_count
    ami = data.aws_ami.ubuntu.id
    availability_zone = var.azs[1]
    instance_type = "t2.micro"
    key_name = aws_key_pair.terraform-key.key_name
    vpc_security_group_ids = [aws_security_group.db.id]
    subnet_id = aws_subnet.az2-private[count.index].id
    source_dest_check = false

    tags ={
        Name = "DB Server${count.index}"
    }
}