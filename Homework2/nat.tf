
/*
  NAT Instance
*/

resource "aws_eip" "nat" {
    count = var.resource_count
    vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
    count = length(aws_subnet.public-subnet.*.id)
    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.public-subnet[count.index].id
    tags = {
     "Name" = "NatGateway ${count.index}"
    }
}


