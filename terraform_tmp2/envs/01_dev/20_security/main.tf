# ../20_security/main.tf
############################################
# SECURITY GROUPS
############################################
module "project02_infra_sg" {
  source = "../../../modules/security-group"
  name   = "project02-infra-sg"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "SSH" },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "HTTP" },
    { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr_block], description = "ICMP" }
  ]
  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

module "project02_was_sg" {
  source = "../../../modules/security-group"
  name   = "project02-was-sg"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "SSH" },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "HTTP" },
    { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr_block], description = "ICMP" }
  ]
  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

module "project02_db_sg" {
  source = "../../../modules/security-group"
  name   = "project02-db-sg"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    { from_port = 5432, to_port = 5432, protocol = "tcp", security_groups = [module.project02_was_sg.sg_id], description = "WAS to DB" },
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "SSH" },
    { from_port = -1, to_port = -1, protocol = "icmp", cidr_blocks = ["10.0.0.0/16"], description = "ICMP (internal test)" }
  ]
  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

module "project02_alb_sg" {
  source = "../../../modules/security-group"
  name   = "project02-alb-sg"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "HTTP" },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "HTTPS" }
  ]
  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

############################################
# IAM ROLE & INSTANCE PROFILE (SSM)
############################################
resource "aws_iam_role" "ssm_role" {
  name = "project02-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "project02-ssm-profile"
  role = aws_iam_role.ssm_role.name
}
