# ../envs/staging/network.tf
############################################
# DATA SOURCES
############################################
data "aws_availability_zones" "available" { state = "available" }

############################################
# SUBNET (staging 전용)
############################################
module "project02_stg_private_subnet_was_a" {
  source        = "../../modules/subnet"
  vpc_id        = local.vpc_id
  cidr_block    = "10.0.40.0/24"
  az            = data.aws_availability_zones.available.names[0]
  map_public_ip = false
  name          = "project02-stg-private-was-a"
}

module "project02_stg_private_subnet_was_b" {
  source        = "../../modules/subnet"
  vpc_id        = local.vpc_id
  cidr_block    = "10.0.41.0/24"
  az            = data.aws_availability_zones.available.names[1]
  map_public_ip = false
  name          = "project02-stg-private-was-b"
}

module "project02_stg_private_subnet_db" {
  source        = "../../modules/subnet"
  vpc_id        = local.vpc_id
  cidr_block    = "10.0.50.0/24"
  az            = data.aws_availability_zones.available.names[0]
  map_public_ip = false
  name          = "project02-stg-private-db"
}

module "project02_stg_public_subnet_alb_a" {
  source        = "../../modules/subnet"
  vpc_id        = local.vpc_id
  cidr_block    = "10.0.4.0/24"
  az            = data.aws_availability_zones.available.names[0]
  map_public_ip = true
  name          = "project02-stg-public-alb-a"
}

module "project02_stg_public_subnet_alb_b" {
  source        = "../../modules/subnet"
  vpc_id        = local.vpc_id
  cidr_block    = "10.0.5.0/24"
  az            = data.aws_availability_zones.available.names[1]
  map_public_ip = true
  name          = "project02-stg-public-alb-b"
}

############################################
# ROUTE TABLES
############################################
# Public route table → Internet Gateway
resource "aws_route_table" "stg_public_rt" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.igw_id
  }
}

# Private route table → NAT instance (0.0.0.0/0 via ENI)
resource "aws_route_table" "stg_private_rt" {
  vpc_id = local.vpc_id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = local.nat_eni_id
  }
}

resource "aws_route_table_association" "stg_alb_a" {
  subnet_id      = module.project02_stg_public_subnet_alb_a.subnet_id
  route_table_id = aws_route_table.stg_public_rt.id
}

resource "aws_route_table_association" "stg_alb_b" {
  subnet_id      = module.project02_stg_public_subnet_alb_b.subnet_id
  route_table_id = aws_route_table.stg_public_rt.id
}

resource "aws_route_table_association" "stg_was_a" {
  subnet_id      = module.project02_stg_private_subnet_was_a.subnet_id
  route_table_id = aws_route_table.stg_private_rt.id
}

resource "aws_route_table_association" "stg_was_b" {
  subnet_id      = module.project02_stg_private_subnet_was_b.subnet_id
  route_table_id = aws_route_table.stg_private_rt.id
}

resource "aws_route_table_association" "stg_db" {
  subnet_id      = module.project02_stg_private_subnet_db.subnet_id
  route_table_id = aws_route_table.stg_private_rt.id
}
