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
# create a frontend route table
resource "aws_route_table" "frontend_route_table" {
  count = length(var.frontend_subnets)
  vpc_id = aws_vpc.vpc.id
  route {
   gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.env}-frontend-rt-tbl-${count.index+1}"
  }
}
# create a backend route table
resource "aws_route_table" "backend_route_table" {
  count = length(var.backend_subnets)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-backend-rt-tbl-${count.index+1}"
  }
}
# create a db route table
resource "aws_route_table" "db_route_table" {
   count = length(var.db_subnets)
  vpc_id = aws_vpc.vpc.id
   tags = {
    Name = "${var.env}-db-rt-tbl-${count.index+1}"
  }
}
# by default there is an association between subnets and route table id
#so when we create a custom route table then we have to associate for custom subnet and with route table id
resource "aws_route_table_association" "frontend-tbl-ass" {
  count = length(var.frontend_subnets)
  subnet_id      = aws_subnet.frontend[count.index].id
  route_table_id = aws_route_table.frontend_route_table[count.index].id
}
# create backend route table association with backend subnet
resource "aws_route_table_association" "backend-tbl-ass" {
  count = length(var.backend_subnets)
  subnet_id      = aws_subnet.backend[count.index].id
  route_table_id = aws_route_table.backend_route_table[count.index].id
}
# create db route table association with db subnet
resource "aws_route_table_association" "db-tbl-ass" {
  count = length(var.db_subnets)
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db_route_table[count.index].id
}
# create an internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-igw"
  }
}
resource "aws_route" "route" {
  count                     = length(var.frontend_subnets)
  route_table_id            = aws_route_table.frontend_route_table[count.index].id
  destination_cidr_block    = var.default_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id

}

# default route table id =rtb-00125ce6494f06f9b