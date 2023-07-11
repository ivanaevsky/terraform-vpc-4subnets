provider "aws" {
  region = var.region
}

resource "aws_vpc" "new_vpc" {
  cidr_block       = var.cidr_vpc
  instance_tenancy = "default"

  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} VPC" })
}

data "aws_availability_zones" "available" {}

resource "aws_internet_gateway" "new_gateway" {
  vpc_id = aws_vpc.new_vpc.id
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} Gateway" })
}

resource "aws_subnet" "private_subnet_A" {
  vpc_id            = aws_vpc.new_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = var.cidr_private_subnet_A
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} Private Subnet A" }) 
}
resource "aws_subnet" "private_subnet_B" {
  vpc_id            = aws_vpc.new_vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = var.cidr_private_subnet_B
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} Private Subnet B" })   
}

resource "aws_subnet" "public_subnet_A" {
  vpc_id            = aws_vpc.new_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  cidr_block        = var.cidr_public_subnet_A
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} Public Subnet A" })   
}

resource "aws_subnet" "public_subnet_B" {
  vpc_id            = aws_vpc.new_vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  cidr_block        = var.cidr_public_subnet_B
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} Public Subnet B" })  
}

resource "aws_route_table" "route_to_gw" {
 vpc_id = aws_vpc.new_vpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.new_gateway.id
 }
 tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} route to IGW" })  
}
resource "aws_route_table_association" "rpa" {
  subnet_id      = aws_subnet.public_subnet_A.id
  route_table_id = aws_route_table.route_to_gw.id
}
resource "aws_route_table_association" "rpb" {
  subnet_id      = aws_subnet.public_subnet_B.id
  route_table_id = aws_route_table.route_to_gw.id
}

resource "aws_eip" "nat_gateway1" {
  vpc = true
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} IP for NAT 1" })
}

resource "aws_nat_gateway" "nat_gateway1" {
  allocation_id = aws_eip.nat_gateway1.id
  subnet_id = aws_subnet.private_subnet_A.id
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} NAT for Private Subnet A" }) 
}

output "nat1_gateway_ip" {
  value = aws_eip.nat_gateway1.public_ip 
}

resource "aws_route_table" "route_to_nat1" {
  vpc_id = aws_vpc.new_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway1.id
  }
}

resource "aws_route_table_association" "assos_r_privateA" {
  subnet_id = aws_subnet.private_subnet_A.id
  route_table_id = aws_route_table.route_to_nat1.id
}

resource "aws_eip" "nat_gateway2" {
  vpc = true
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} IP for NAT 2" })
}

resource "aws_nat_gateway" "nat_gateway2" {
  allocation_id = aws_eip.nat_gateway2.id
  subnet_id = aws_subnet.private_subnet_B.id
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} NAT for Private Subnet B" }) 
}

output "nat2_gateway_ip" {
  value = aws_eip.nat_gateway2.public_ip
}

resource "aws_route_table" "route_to_nat2" {
  vpc_id = aws_vpc.new_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway2.id
  }
}

resource "aws_route_table_association" "assos_r_privateB" {
  subnet_id = aws_subnet.private_subnet_B.id
  route_table_id = aws_route_table.route_to_nat2.id
}