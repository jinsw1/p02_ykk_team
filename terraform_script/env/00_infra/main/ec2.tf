############################################
# DATA SOURCES (AMI / AZ)
############################################
data "aws_ami" "latest_al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}


############################################
# KEYPAIRS
############################################
module "project02_infra_ec2_key" {
  source   = "../../../modules/keypair"
  key_name = "project02-infra-key"
}

module "project02_was_ec2_key" {
  source   = "../../../modules/keypair"
  key_name = "project02-was-key"
}

module "project02_db_ec2_key" {
  source   = "../../../modules/keypair"
  key_name = "project02-db-key"
}


############################################
# EC2 INSTANCES (Infra + WAS1 + WAS2 + DB)
############################################
module "project02_infra_ec2" {
  source               = "../../../modules/ec2"
  instance_type        = "t3.micro"
  subnet_id            = module.project02_private_subnet_infra.subnet_id
  security_group_ids   = [module.project02_infra_sg.sg_id]
  key_name             = module.project02_infra_ec2_key.key_name
  name                 = "project02-infra"
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  # NAT + private_rt 생성 완료 후에만 실행
  depends_on = [
    aws_instance.nat_instance,
    aws_route_table.private_rt
  ]

  user_data = <<-EOF
    #!/bin/bash -eux
    until curl -s https://pkgs.tailscale.com >/dev/null; do sleep 5; done
    curl -fsSL https://tailscale.com/install.sh | sh
    systemctl enable --now tailscaled
    sysctl --system
    tailscale up \
      --auth-key=${tailscale_tailnet_key.ec2_join_key.key} \
      --hostname=project02 \
      --advertise-routes=${module.project02_vpc.cidr_block} \
      --accept-routes \
      --ssh
  EOF
}

module "project02_was01_ec2" {
  source               = "../../../modules/ec2"
  instance_type        = "t3.micro"
  subnet_id            = module.project02_private_subnet_was.subnet_id
  security_group_ids   = [module.project02_was_sg.sg_id]
  key_name             = module.project02_was_ec2_key.key_name
  name                 = "project02-was01"
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
}

module "project02_was02_ec2" {
  source               = "../../../modules/ec2"
  instance_type        = "t3.micro"
  subnet_id            = module.project02_private_subnet_was.subnet_id
  security_group_ids   = [module.project02_was_sg.sg_id]
  key_name             = module.project02_was_ec2_key.key_name
  name                 = "project02-was02"
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
}

module "project02_db_ec2" {
  source               = "../../../modules/ec2"
  instance_type        = "t3.micro"
  subnet_id            = module.project02_private_subnet_db.subnet_id
  security_group_ids   = [module.project02_db_sg.sg_id]
  key_name             = module.project02_db_ec2_key.key_name
  name                 = "project02-db"
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
}