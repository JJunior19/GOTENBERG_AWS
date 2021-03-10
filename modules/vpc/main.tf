resource "aws_subnet" "gotenberg-subnet-public" {
    vpc_id = aws_vpc.gotenberg-vpc.id
    cidr_block = "10.0.0.0/24"
    tags = {
      "Name" = "uoc-${var.app_env}-gotenberg-subnet-${var.uocenv}"
    }
}
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.gotenberg-vpc.id
    tags = {
      "Name" = "uoc-${var.app_env}-gotenberg-route-table-${var.uocenv}"
    }

}
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.gotenberg-vpc.id
    tags = {
      "Name" = "uoc-${var.app_env}-gotenberg-route-table-public-${var.uocenv}"
    }
}
resource "aws_route" "public" {
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.gotenberg_igw.id
}
resource "aws_route" "private" {
    route_table_id = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gotenberg-natway.id
}

resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.gotenberg-subnet.id
    route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.gotenberg-subnet-public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_vpc" "gotenberg-vpc" { 
  cidr_block = "10.0.0.0/16" 
  enable_dns_hostnames = true
  tags = {
    "Name" = "uoc-${var.app_env}-gotenberg-vpc-${var.uocenv}"
  }
}
resource "aws_nat_gateway" "gotenberg-natway" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.gotenberg-subnet-public.id
    tags = {
      "Name" = "uoc-${var.app_env}-gotenberg-natway-${var.uocenv}"
    }
    depends_on = [ aws_internet_gateway.gotenberg_igw ]
}
resource "aws_eip" "nat_eip" {
    vpc = true
    tags = {
      "Name" = "uoc-${var.app_env}-gotenberg-eip-nat-${var.uocenv}"
    }
}
resource "aws_network_interface" "private" {
    subnet_id = aws_subnet.gotenberg-subnet.id
    tags = {
      "Name" = "uoc-${var.app_env}-gotenberg-ENI-${var.uocenv}"
    }
}
resource "aws_internet_gateway" "gotenberg_igw" {
    vpc_id = aws_vpc.gotenberg-vpc.id
    tags = {
      "Name" = "uoc-${var.app_env}-gotenberg-IGW-${var.uocenv}"
    }
}
resource "aws_subnet" "gotenberg-subnet" {
    vpc_id = aws_vpc.gotenberg-vpc.id
    cidr_block = "10.0.1.0/24"
    tags = {
      "Name" = "uoc-${var.app_env}-gotenberg-subnet-${var.uocenv}"
    }
}
