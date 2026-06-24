# ../envs/dev/security.tf
############################################
# SECURITY GROUPS (Layered access control)
############################################
# WAS SG - app servers (HTTP/HTTPS exposed internally + SSH)
module "project02_staging_was_sg" {
  source = "../../modules/security-group"
  name   = "project02-staging-was-sg"
  vpc_id = local.vpc_id

  ingress_rules = [
    {
      from_port   = 22,
      to_port     = 22,
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"],
      description = "SSH"
    },
    {
      from_port   = 80,
      to_port     = 80,
      protocol    = "tcp",
      #cidr_blocks = ["0.0.0.0/0"],
	  security_groups = [module.project02_staging_alb_sg.sg_id]
      description = "HTTP app"
    },
    { from_port   = 8080,
      to_port     = 8080,
      protocol    = "tcp",
      security_groups = [local.infra_sg_id],
      description = "Prometheus to Was cadvisor"
    },		
    { from_port   = 443,
      to_port     = 443,
      protocol    = "tcp",
     # cidr_blocks = ["0.0.0.0/0"],
	  security_groups = [module.project02_staging_alb_sg.sg_id]
      description = "HTTPS app"
    },
    { from_port   = 9100,
      to_port     = 9100,
      protocol    = "tcp",
      security_groups = [local.infra_sg_id],
      description = "Prometheus to Was Node_exporter"
    },	
    {
      from_port   = -1,
      to_port     = -1,
      protocol    = "icmp",
      cidr_blocks = [local.vpc_cidr_block],
      description = "internal test"
    }
  ]

  egress_rules = [
    {
      from_port   = 0,
      to_port     = 0,
      protocol    = "-1",
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# DB SG - strict access (WAS only allowed to 5432)
module "project02_staging_db_sg" {
  source = "../../modules/security-group"
  name   = "project02-staging-db-sg"
  vpc_id = local.vpc_id

  ingress_rules = [
    {
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [module.project02_staging_was_sg.sg_id]
      description     = "WAS to PostgreSQL"
    },
    {
      from_port       = 9100
      to_port         = 9100
      protocol        = "tcp"
      security_groups = [local.infra_sg_id]
      description = "Prometheus to Was Node_exporter"
    },
    { from_port   = 8080,
      to_port     = 8080,
      protocol    = "tcp",
      security_groups = [local.infra_sg_id],
      description = "Prometheus to Was cadvisor"
    },		
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH admin"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# ALB SG 
module "project02_staging_alb_sg" {
  source = "../../modules/security-group"
  name   = "project02-staging-alb-sg"
  vpc_id = local.vpc_id

  ingress_rules = [
    {
      from_port   = 80,
      to_port     = 80,
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"],
      description = "HTTP"
    },
    {
      from_port   = 443,
      to_port     = 443,
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"],
      description = "HTTPS"
    }
  ]
  egress_rules = [
    {
      from_port   = 0,
      to_port     = 0,
      protocol    = "-1",
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}