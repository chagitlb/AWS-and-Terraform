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
  Public Subnet
*/
resource "aws_subnet" "public-subnet" {
    count = length(var.public_subnet_cidr)
    vpc_id = aws_vpc.default.id

    cidr_block = var.public_subnet_cidr[count.index]
    availability_zone = var.azs[count.index]

    tags ={
        Name = "Public Subnet ${count.index}"
    }
}

resource "aws_route_table" "public-route" {
    count = length(aws_subnet.public-subnet.*.id)
    vpc_id = aws_vpc.default.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.default.id
    }

    tags ={
        Name = "Public Subnet ${count.index}"
    }
}

resource "aws_route_table_association" "public-association" {
    count = length(aws_route_table.public-route.*.id) 
    subnet_id = aws_subnet.public-subnet[count.index].id
    route_table_id = aws_route_table.public-route[count.index].id
}

/*
  Private Subnet
*/
resource "aws_subnet" "private-subnet" {
    count = length(var.private_subnet_cidr)
    vpc_id = aws_vpc.default.id
    cidr_block = var.private_subnet_cidr[count.index]
    availability_zone = var.azs[count.index]
    tags ={
        Name = "Private Subnet ${count.index}"
    }
}

resource "aws_route_table" "private-route" {
    vpc_id = aws_vpc.default.id
    count = length(aws_subnet.private-subnet.*.id)
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
    }

    tags ={
        Name = "Private Subnet"
    }
}

resource "aws_route_table_association" "private-association" {
    count = length(aws_route_table.private-route.*.id)
    subnet_id = aws_subnet.private-subnet[count.index].id
    route_table_id = aws_route_table.private-route[count.index].id
}