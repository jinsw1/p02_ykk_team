# ../envs/dev/network.tf
############################################
# DATA SOURCES (AZ)
############################################
data "aws_availability_zones" "available" { state = "available" }

############################################
# SUBNET DESIGN (Public / Private)
############################################
# Private Subnet - WAS A (AZ-1)
module "project02_staging_private_subnet_was_a" {
  source        = "../../modules/subnet"
  vpc_id        = local.vpc_id
  cidr_block    = "10.0.120.0/24"
  az            = data.aws_availability_zones.available.names[0]
  map_public_ip = false
  name          = "project02-staging-private-was-a"
}

# Private Subnet - WAS B (AZ-2)
module "project02_staging_private_subnet_was_b" {
  source        = "../../modules/subnet"
  vpc_id        = local.vpc_id
  cidr_block    = "10.0.121.0/24"
  az            = data.aws_availability_zones.available.names[1]
  map_public_ip = false
  name          = "project02-staging-private-was-b"
}

# Private Subnet - DB Layer
module "project02_staging_private_subnet_db" {
  source        = "../../modules/subnet"
  vpc_id        = local.vpc_id
  cidr_block    = "10.0.130.0/24"
  az            = data.aws_availability_zones.available.names[0]
  map_public_ip = false
  name          = "project02-staging-private-db"
}

# Public Subnet - ALB A
module "project02_staging_public_subnet_alb_a" {
  source        = "../../modules/subnet"
  vpc_id        = local.vpc_id
  cidr_block    = "10.0.102.0/24"
  az            = data.aws_availability_zones.available.names[0]
  map_public_ip = true
  name          = "project02-staging-public-alb-a"
}

# Public Subnet - ALB B
module "project02_staging_public_subnet_alb_b" {
  source        = "../../modules/subnet"
  vpc_id        = local.vpc_id
  cidr_block    = "10.0.103.0/24"
  az            = data.aws_availability_zones.available.names[1]
  map_public_ip = true
  name          = "project02-staging-public-alb-b"
}

############################################
# ROUTE TABLES (Traffic routing rules)
############################################

data "aws_route_table" "public_rt" {
  filter {
    name   = "tag:Name"
    values = ["project02-public-rt"]
  }
}

data "aws_route_table" "private_rt" {
  filter {
    name   = "tag:Name"
    values = ["project02-private-rt"]
  }
}

resource "aws_route_table_association" "staging_alb_a" {
  subnet_id      = module.project02_staging_public_subnet_alb_a.subnet_id
  route_table_id = data.aws_route_table.public_rt.id
}

resource "aws_route_table_association" "staging_alb_b" {
  subnet_id      = module.project02_staging_public_subnet_alb_b.subnet_id
  route_table_id = data.aws_route_table.public_rt.id
}

resource "aws_route_table_association" "staging_was_a_rt" {
  subnet_id      = module.project02_staging_private_subnet_was_a.subnet_id
  route_table_id = data.aws_route_table.private_rt.id
}
resource "aws_route_table_association" "staging_was_b_rt" {
  subnet_id      = module.project02_staging_private_subnet_was_b.subnet_id
  route_table_id = data.aws_route_table.private_rt.id
}

resource "aws_route_table_association" "staging_db_rt" {
  subnet_id      = module.project02_staging_private_subnet_db.subnet_id
  route_table_id = data.aws_route_table.private_rt.id
}