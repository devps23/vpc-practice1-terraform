// create vpc
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_id
  tags = {
    Name = "${var.env}-vpc"
  }
}
# create public  subnets
resource "aws_subnet" "public_subnets" {
  count      = length(var.public_subnets)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env}-public-${count.index+1}"
  }
}
# create frontend subnets
resource "aws_subnet" "frontend_subnets" {
  count      = length(var.frontend_subnets)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.frontend_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.env}-frontend-${count.index+1}"
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
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }
  route{
    cidr_block = var.default_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }
  tags = {
    Name = "${var.env}-frontend-rt-tbl-${count.index+1}"
  }
}
# create a public  route table
resource "aws_route_table" "public_route_table" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.vpc.id
  route{
    cidr_block = var.default_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }
  tags = {
    Name = "${var.env}-public-rt-tbl-${count.index+1}"
  }
}

# create public route table association with backend subnet
resource "aws_route_table_association" "public-tbl-ass" {
  count = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table[count.index].id
}
# by default there is an association between subnets and route table id
#so when we create a custom route table then we have to associate for custom subnet and with route table id
resource "aws_route_table_association" "frontend-tbl-ass" {
  count = length(var.frontend_subnets)
  subnet_id      = aws_subnet.frontend_subnets[count.index].id
  route_table_id = aws_route_table.frontend_route_table[count.index].id
}
# create an internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-igw"
  }
}
resource "aws_nat_gateway" "nat_gateway" {
  count = length(var.public_subnets)
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name = "${var.env}-nat"
  }
}
#  create a eip
resource "aws_eip" "eip" {
  count = length(var.public_subnets)
  domain   = "vpc"
}
# resource "aws_route" "frontend_route" {
#   count                     = length(var.frontend_subnets)
#   route_table_id            = aws_route_table.frontend_route_table[count.index].id
#   destination_cidr_block    = var.default_cidr_block
#   vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
# }
# create a nat gateway

# # create backend subnets
# resource "aws_subnet" "backend" {
#   count      = length(var.backend_subnets)
#   vpc_id     = aws_vpc.vpc.id
#   cidr_block = var.backend_subnets[count.index]
#   availability_zone = var.availability_zones[count.index]
#   tags = {
#     Name = "${var.env}-backend-${count.index+1}"
#   }
# }
# # create db subnets
# resource "aws_subnet" "db" {
#   count      = length(var.db_subnets)
#   vpc_id     = aws_vpc.vpc.id
#   cidr_block = var.db_subnets[count.index]
#   availability_zone = var.availability_zones[count.index]
#   tags = {
#     Name = "${var.env}-db-${count.index+1}"
#   }
# }

# create a backend route table
# resource "aws_route_table" "backend_route_table" {
#   count = length(var.backend_subnets)
#   vpc_id = aws_vpc.vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_gateway.id
#   }
#   tags = {
#     Name = "${var.env}-backend-rt-tbl-${count.index+1}"
#   }
# }
# # create a db route table
# resource "aws_route_table" "db_route_table" {
#    count = length(var.db_subnets)
#   vpc_id = aws_vpc.vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_gateway.id
#   }
#    tags = {
#     Name = "${var.env}-db-rt-tbl-${count.index+1}"
#   }
# }
# create backend route table association with backend subnet
# resource "aws_route_table_association" "backend-tbl-ass" {
#   count = length(var.backend_subnets)
#   subnet_id      = aws_subnet.backend[count.index].id
#   route_table_id = aws_route_table.backend_route_table[count.index].id
# }
# # create db route table association with db subnet
# resource "aws_route_table_association" "db-tbl-ass" {
#   count = length(var.db_subnets)
#   subnet_id      = aws_subnet.db[count.index].id
#   route_table_id = aws_route_table.db_route_table[count.index].id
# }

# resource "aws_route" "backend_route" {
#   count                     = length(var.backend_subnets)
#   route_table_id            = aws_route_table.backend_route_table[count.index].id
#   destination_cidr_block    = var.default_cidr_block
#   vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
# }
# resource "aws_route" "db_route" {
#   count                     = length(var.db_subnets)
#   route_table_id            = aws_route_table.db_route_table[count.index].id
#   destination_cidr_block    = var.default_cidr_block
#   vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
# }
# resource "aws_route" "public_route" {
#   count                     = length(var.public_subnets)
#   route_table_id            = aws_route_table.public_route_table[count.index].id
#   destination_cidr_block    = var.default_cidr_block
#   vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
# }



# default route table id =rtb-00125ce6494f06f9b