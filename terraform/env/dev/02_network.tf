# 02_network.tf

module "vpc" {
  source   = "../../modules/01_vpc"
  vpc_cidr = var.vpc_cidr
  project  = var.project
}

module "subnet_public_proxy" {
  source        = "../../modules/02_subnet"
  vpc_id        = module.vpc.vpc_id
  cidr_block    = var.public_subnet_proxy_cidr
  az            = var.az
  map_public_ip = true
  name          = "${var.project}-public-subnet-proxy"
}

module "subnet_public_nat" {
  source        = "../../modules/02_subnet"
  vpc_id        = module.vpc.vpc_id
  cidr_block    = var.public_subnet_nat_cidr
  az            = var.az
  map_public_ip = true
  name          = "${var.project}-public-subnet-nat"
}

module "subnet_public_bastion" {
  source        = "../../modules/02_subnet"
  vpc_id        = module.vpc.vpc_id
  cidr_block    = var.public_subnet_bastion_cidr
  az            = var.az
  map_public_ip = true
  name          = "${var.project}-public-subnet-bastion"
}

module "subnet_private_app" {
  source        = "../../modules/02_subnet"
  vpc_id        = module.vpc.vpc_id
  cidr_block    = var.private_subnet_app_cidr
  az            = var.az
  map_public_ip = false
  name          = "${var.project}-private-app-subnet01"
}

module "subnet_private_db" {
  source        = "../../modules/02_subnet"
  vpc_id        = module.vpc.vpc_id
  cidr_block    = var.private_subnet_db_cidr
  az            = var.az
  map_public_ip = false
  name          = "${var.project}-private-db-subnet"
}

module "rt_public" {
  source     = "../../modules/03_rt"
  vpc_id     = module.vpc.vpc_id
  gateway_id = module.vpc.igw_id
  subnet_id  = module.subnet_public_proxy.subnet_id
  name       = "${var.project}-public-rt"
}

resource "aws_route_table_association" "nat" {
  subnet_id      = module.subnet_public_nat.subnet_id
  route_table_id = module.rt_public.rt_id
}

resource "aws_route_table_association" "bastion" {
  subnet_id      = module.subnet_public_bastion.subnet_id
  route_table_id = module.rt_public.rt_id
}

module "rt_private" {
  source               = "../../modules/03_rt"
  vpc_id               = module.vpc.vpc_id
  network_interface_id = module.ec2_nat.network_interface_id
  subnet_id            = module.subnet_private_app.subnet_id
  name                 = "${var.project}-private-rt"
}

resource "aws_route_table_association" "db" {
  subnet_id      = module.subnet_private_db.subnet_id
  route_table_id = module.rt_private.rt_id
}
