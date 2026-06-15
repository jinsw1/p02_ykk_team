############################################
# SECURITY GROUPS
############################################
module "project02_infra_sg" {
  source = "../../../modules/security-group"
  name   = "project02-infra-sg"
  vpc_id = module.project02_vpc.vpc_id

  ingress_rules = [
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "SSH" },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "HTTP" },
    { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = [module.project02_vpc.cidr_block], description = "ICMP" }
  ]
  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

module "project02_was_sg" {
  source = "../../../modules/security-group"
  name   = "project02-was-sg"
  vpc_id = module.project02_vpc.vpc_id

  ingress_rules = [
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "SSH" },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "HTTP" },
    { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = [module.project02_vpc.cidr_block], description = "ICMP" }
  ]
  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

module "project02_db_sg" {
  source = "../../../modules/security-group"
  name   = "project02-db-sg"
  vpc_id = module.project02_vpc.vpc_id

  ingress_rules = [
    { from_port = 5432, to_port = 5432, protocol = "tcp", cidr_blocks = ["10.0.20.0/24"], description = "WAS to DB" },
    { from_port = 22,   to_port = 22,   protocol = "tcp", cidr_blocks = ["0.0.0.0/0"],    description = "SSH" },
    { from_port = -1,   to_port = -1,   protocol = "icmp", cidr_blocks = ["10.0.0.0/16"], description = "ICMP (internal test)" }
  ]
  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

module "project02_alb_sg" {
  source = "../../../modules/security-group"
  name   = "project02-alb-sg"
  vpc_id = module.project02_vpc.vpc_id

  ingress_rules = [
    { from_port = 80,  to_port = 80,  protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "HTTP" },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "HTTPS" }
  ]
  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}
