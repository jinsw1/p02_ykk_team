# network.tf

# VPC
module "vpc" {
  source              = "../../modules/01_vpc"
  project             = var.project
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_app_cidr    = var.private_app_cidr
  private_db_cidr     = var.private_db_cidr
  az                  = var.az
}


# Security groups
module "proxy_sg" {
  source  = "../../modules/02_sg"
  project = var.project
  name    = "proxy"
  vpc_id  = module.vpc.vpc_id
}

module "app_sg" {
  source  = "../../modules/02_sg"
  project = var.project
  name    = "app"
  vpc_id  = module.vpc.vpc_id
}

module "db_sg" {
  source  = "../../modules/02_sg"
  project = var.project
  name    = "db"
  vpc_id  = module.vpc.vpc_id
}

module "bastion_sg" {
  source  = "../../modules/02_sg"
  project = var.project
  name    = "bastion"
  vpc_id  = module.vpc.vpc_id
}

module "nat_sg" {
  source  = "../../modules/02_sg"
  project = var.project
  name    = "nat"
  vpc_id  = module.vpc.vpc_id
}


# Security group rules

# bastion
resource "aws_security_group_rule" "bastion_ingress_ssh" {
  type              = "ingress"
  security_group_id = module.bastion_sg.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip]
}

resource "aws_security_group_rule" "bastion_egress_all" {
  type              = "egress"
  security_group_id = module.bastion_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# proxy
resource "aws_security_group_rule" "proxy_ingress_ssh" {
  type                     = "ingress"
  security_group_id        = module.proxy_sg.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.id
}

resource "aws_security_group_rule" "proxy_ingress_http" {
  type              = "ingress"
  security_group_id = module.proxy_sg.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "proxy_ingress_https" {
  type              = "ingress"
  security_group_id = module.proxy_sg.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "proxy_egress_to_app" {
  type                     = "egress"
  security_group_id        = module.proxy_sg.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.app_sg.id
}

# app
resource "aws_security_group_rule" "app_ingress_ssh" {
  type                     = "ingress"
  security_group_id        = module.app_sg.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.id
}

resource "aws_security_group_rule" "app_ingress_from_proxy" {
  type                     = "ingress"
  security_group_id        = module.app_sg.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.proxy_sg.id
}

resource "aws_security_group_rule" "app_egress_all" {
  type              = "egress"
  security_group_id = module.app_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# db
resource "aws_security_group_rule" "db_ingress_ssh" {
  type                     = "ingress"
  security_group_id        = module.db_sg.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.id
}

resource "aws_security_group_rule" "db_ingress_from_app" {
  type                     = "ingress"
  security_group_id        = module.db_sg.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.app_sg.id
}

resource "aws_security_group_rule" "db_egress_all" {
  type              = "egress"
  security_group_id = module.db_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# nat
resource "aws_security_group_rule" "nat_ingress_from_private" {
  type              = "ingress"
  security_group_id = module.nat_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.private_app_cidr, var.private_db_cidr]
}

resource "aws_security_group_rule" "nat_egress_all" {
  type              = "egress"
  security_group_id = module.nat_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
