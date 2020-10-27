resource "aws_vpc" "default" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    tags ={
        Name = "terraform-aws-vpc"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = aws_vpc.default.id
}

/*
  NAT Instance
*/
resource "aws_security_group" "nat" {
    name = "vpc_nat"
    description = "Allow traffic to pass from the private subnet to the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [var.private_subnet_cidr]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [var.private_subnet_cidr]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
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
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = aws_vpc.default.id

    tags ={
        Name = "NATSG"
    }
}

resource "aws_instance" "nat" {
    count = var.resource_count
    ami = data.aws_ami.ubuntu.id
    availability_zone = var.azs[count.index]
    instance_type = "t2.micro"
    key_name = aws_key_pair.terraform-key.key_name
    vpc_security_group_ids = [aws_security_group.nat.id]
    subnet_id = aws_subnet.az1-public.id
    associate_public_ip_address = true
    source_dest_check = false

    tags ={
        Name = "vpc_nat${count.index}"
    }
}

resource "aws_eip" "nat" {
    count = var.resource_count
    instance = aws_instance.nat[count.index].id
    vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
    count = var.resource_count
    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.az1-public.id
    tags = {
     "Name" = "NatGateway"
    }
}
/*
  Public Subnet
*/
resource "aws_subnet" "az1-public" {
    vpc_id = aws_vpc.default.id

    cidr_block = var.public_subnet_cidr
    availability_zone = var.azs[0]

    tags ={
        Name = "Public Subnet"
    }
}

resource "aws_route_table" "az1-public" {
    vpc_id = aws_vpc.default.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.default.id
    }

    tags ={
        Name = "Public Subnet"
    }
}

resource "aws_route_table_association" "az1-public" {
    subnet_id = aws_subnet.az1-public.id
    route_table_id = aws_route_table.az1-public.id
}

/*
  Private Subnet
*/
resource "aws_subnet" "az2-private" {
    count = var.resource_count
    vpc_id = aws_vpc.default.id
    cidr_block = var.private_subnet_cidr
    availability_zone = var.azs[count.index]
    tags ={
        Name = "Private Subnet"
    }
}

resource "aws_route_table" "az2-private" {
    vpc_id = aws_vpc.default.id
    count = var.resource_count
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
    }

    tags ={
        Name = "Private Subnet"
    }
}

resource "aws_route_table_association" "az2-private" {
    count = var.resource_count
    subnet_id = aws_subnet.az2-private[count.index].id
    route_table_id = aws_route_table.az2-private[count.index].id
}