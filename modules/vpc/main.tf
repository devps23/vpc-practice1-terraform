// create vpc
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_id
  tags = {
    Name = "${var.env}-vpc"
  }
}
# create frontend subnets
resource "aws_subnet" "frontend" {
  count      = length(var.frontend_subnets)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.frontend_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.env}-frontend-${count.index+1}"
  }
}
# create backend subnets
resource "aws_subnet" "backend" {
  count      = length(var.backend_subnets)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.backend_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.env}-backend-${count.index+1}"
  }
}
# create db subnets
resource "aws_subnet" "db" {
  count      = length(var.db_subnets)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.db_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.env}-db-${count.index+1}"
  }
}
# peer connection between two vpc id's
resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.vpc.id
  auto_accept   = true
  tags = {
    Name = "${var.env}--peer"
  }
}
# create a route table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
}
