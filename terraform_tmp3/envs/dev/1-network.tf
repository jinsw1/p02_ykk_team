# ../envs/dev/network.tf
############################################
# DATA SOURCES (AZ)
############################################
data "aws_availability_zones" "available" { state = "available" }

############################################
# SUBNET DESIGN (Public / Private)
############################################
# Private Subnet - WAS A (AZ-1)
module "project02_private_subnet_was_a" {
  source        = "../../modules/subnet"
  vpc_id        = local.vpc_id
  cidr_block    = "10.0.20.0/24"
  az            = data.aws_availability_zones.available.names[0]
  map_public_ip = false
  name          = "project02-private-was-a"
}

# Private Subnet - WAS B (AZ-2)
module "project02_private_subnet_was_b" {
  source        = "../../modules/subnet"
  vpc_id        = local.vpc_id
  cidr_block    = "10.0.21.0/24"
  az            = data.aws_availability_zones.available.names[1]
  map_public_ip = false
  name          = "project02-private-was-b"
}

# Private Subnet - DB Layer
module "project02_private_subnet_db" {
  source        = "../../modules/subnet"
  vpc_id        = local.vpc_id
  cidr_block    = "10.0.30.0/24"
  az            = data.aws_availability_zones.available.names[0]
  map_public_ip = false
  name          = "project02-private-db"
}

# Public Subnet - ALB A
module "project02_public_subnet_alb_a" {
  source        = "../../modules/subnet"
  vpc_id        = local.vpc_id
  cidr_block    = "10.0.2.0/24"
  az            = data.aws_availability_zones.available.names[0]
  map_public_ip = true
  name          = "project02-public-alb-a"
}

# Public Subnet - ALB B
module "project02_public_subnet_alb_b" {
  source        = "../../modules/subnet"
  vpc_id        = local.vpc_id
  cidr_block    = "10.0.3.0/24"
  az            = data.aws_availability_zones.available.names[1]
  map_public_ip = true
  name          = "project02-public-alb-b"
}

############################################
# ROUTE TABLES (Traffic routing rules)
############################################
# Public route table → Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.igw_id
  }
}

# Private route table → NAT instance (0.0.0.0/0 via ENI)
resource "aws_route_table" "private_rt" {
  vpc_id = local.vpc_id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = local.nat_eni_id
  }
}

resource "aws_route_table_association" "alb_a" {
  subnet_id      = module.project02_public_subnet_alb_a.subnet_id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "alb_b" {
  subnet_id      = module.project02_public_subnet_alb_b.subnet_id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "was_a_rt" {
  subnet_id      = module.project02_private_subnet_was_a.subnet_id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "was_b_rt" {
  subnet_id      = module.project02_private_subnet_was_b.subnet_id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "db_rt" {
  subnet_id      = module.project02_private_subnet_db.subnet_id
  route_table_id = aws_route_table.private_rt.id
}
