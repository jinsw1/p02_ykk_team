# 03_sg.tf

module "sg_proxy" {
  source        = "../../modules/04_sg"
  project       = var.project
  name          = "proxy"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = []
  egress_rules  = []
}

module "sg_app" {
  source        = "../../modules/04_sg"
  project       = var.project
  name          = "app"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = []
  egress_rules  = []
}

module "sg_db" {
  source        = "../../modules/04_sg"
  project       = var.project
  name          = "db"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = []
  egress_rules  = []
}

module "sg_bastion" {
  source        = "../../modules/04_sg"
  project       = var.project
  name          = "bastion"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = []
  egress_rules  = []
}

module "sg_nat" {
  source        = "../../modules/04_sg"
  project       = var.project
  name          = "nat"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = []
  egress_rules  = []
}

resource "aws_security_group_rule" "proxy_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.sg_proxy.sg_id
}

resource "aws_security_group_rule" "proxy_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.sg_proxy.sg_id
}

resource "aws_security_group_rule" "proxy_egress_app" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.sg_app.sg_id
  security_group_id        = module.sg_proxy.sg_id
}

resource "aws_security_group_rule" "app_ingress_proxy" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.sg_proxy.sg_id
  security_group_id        = module.sg_app.sg_id
}

resource "aws_security_group_rule" "app_ingress_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.sg_bastion.sg_id
  security_group_id        = module.sg_app.sg_id
}

resource "aws_security_group_rule" "app_egress_db" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.sg_db.sg_id
  security_group_id        = module.sg_app.sg_id
}

resource "aws_security_group_rule" "db_ingress_app" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.sg_app.sg_id
  security_group_id        = module.sg_db.sg_id
}

resource "aws_security_group_rule" "db_ingress_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.sg_bastion.sg_id
  security_group_id        = module.sg_db.sg_id
}

resource "aws_security_group_rule" "bastion_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.mgmt_ip]
  security_group_id = module.sg_bastion.sg_id
}

resource "aws_security_group_rule" "bastion_egress_app" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.sg_app.sg_id
  security_group_id        = module.sg_bastion.sg_id
}

resource "aws_security_group_rule" "bastion_egress_db" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.sg_db.sg_id
  security_group_id        = module.sg_bastion.sg_id
}

resource "aws_security_group_rule" "nat_ingress_private" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.private_subnet_app_cidr, var.private_subnet_db_cidr]
  security_group_id = module.sg_nat.sg_id
}

resource "aws_security_group_rule" "nat_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.sg_nat.sg_id
}



# =========== NAT 접속해서 ip forward 확인하기 위해 ssh 열기 ==========

resource "aws_security_group_rule" "nat_ingress_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.sg_bastion.sg_id
  security_group_id        = module.sg_nat.sg_id
}

resource "aws_security_group_rule" "bastion_egress_nat" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.sg_nat.sg_id
  security_group_id        = module.sg_bastion.sg_id
}