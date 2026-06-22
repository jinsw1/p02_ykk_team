# ../envs/staging/security.tf
############################################
# SECURITY GROUPS
############################################
module "stg_was_sg" {
  source = "../../modules/security-group"
  name   = "stg-was-sg"
  vpc_id = local.vpc_id

  ingress_rules = [
    { from_port = 22,  to_port = 22,  protocol = "tcp", cidr_blocks = ["100.64.0.0/10"], description = "SSH" },
    { from_port = 80,  to_port = 80,  protocol = "tcp", cidr_blocks = ["0.0.0.0/0"],     description = "HTTP" },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"],     description = "HTTPS" }
  ]

  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

module "stg_db_sg" {
  source = "../../modules/security-group"
  name   = "stg-db-sg"
  vpc_id = local.vpc_id

  ingress_rules = [
    {
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [module.stg_was_sg.sg_id]
      description     = "PostgreSQL from WAS"
    },
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["100.64.0.0/10"], description = "SSH" }
  ]

  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

module "stg_alb_sg" {
  source = "../../modules/security-group"
  name   = "stg-alb-sg"
  vpc_id = local.vpc_id

  ingress_rules = [
    { from_port = 80,  to_port = 80,  protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "HTTP" },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "HTTPS" }
  ]

  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}