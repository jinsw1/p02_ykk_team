# ../envs/infra/network.tf
############################################
# DATA SOURCES (AZ)
############################################
data "aws_availability_zones" "available" { state = "available" }

############################################
# VPC/IGW
############################################
module "project02_vpc" {
  source     = "../../modules/vpc"
  cidr_block = "10.0.0.0/16"
  name       = "project02-vpc"
}

module "project02_igw" {
  source = "../../modules/internet-gateway"
  vpc_id = module.project02_vpc.vpc_id
  name   = "project02-igw"
}

############################################
# SUBNETS (Private: infra, Public: nat)
############################################
# Private Subnet - Infra (Bastion/Router 역할)
module "project02_private_subnet_infra" {
  source        = "../../modules/subnet"
  vpc_id        = module.project02_vpc.vpc_id
  cidr_block    = "10.0.10.0/24"
  az            = data.aws_availability_zones.available.names[0]
  map_public_ip = false
  name          = "project02-private-infra"
}

# Public Subnet - NAT instance
module "project02_public_subnet_nat" {
  source        = "../../modules/subnet"
  vpc_id        = module.project02_vpc.vpc_id
  cidr_block    = "10.0.1.0/24"
  az            = data.aws_availability_zones.available.names[0]
  map_public_ip = true
  name          = "project02-public-nat"
}

############################################
# ROUTE TABLES
############################################
# Public route table → Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = module.project02_vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.project02_igw.igw_id
  }

  tags = {
    Name = "project02-public-rt"
  }

}

resource "aws_route_table_association" "infra_rt" {
  subnet_id      = module.project02_private_subnet_infra.subnet_id
  route_table_id = aws_route_table.private_rt.id
}

# nat
# Public subnet associations
resource "aws_route_table_association" "public_nat_rt" {
  subnet_id      = module.project02_public_subnet_nat.subnet_id
  route_table_id = aws_route_table.public_rt.id
}

# Private route table → NAT instance (0.0.0.0/0 via ENI)
resource "aws_route_table" "private_rt" {
  vpc_id = module.project02_vpc.vpc_id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat_instance.primary_network_interface_id
  }

  tags = {
    Name = "project02-private-rt"
  }  
}