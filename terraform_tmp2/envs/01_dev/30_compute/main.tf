# ../30_compute/main.tf
############################################
# DATA SOURCES (AMI)
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
# KEYPAIR
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
  subnet_id            = data.terraform_remote_state.network.outputs.private_subnet_infra_id
  security_group_ids   = [data.terraform_remote_state.security.outputs.infra_sg_id]
  key_name             = module.project02_infra_ec2_key.key_name
  name                 = "project02-infra"
  iam_instance_profile = data.terraform_remote_state.security.outputs.ssm_instance_profile_name

  user_data = <<-EOF
    #!/bin/bash -eux
    until curl -s https://pkgs.tailscale.com >/dev/null; do sleep 5; done
    curl -fsSL https://tailscale.com/install.sh | sh
    systemctl enable --now tailscaled
    sysctl --system
    tailscale up \
      --auth-key=${data.terraform_remote_state.vpn_key.outputs.ec2_join_key} \
      --hostname=project02 \
      --advertise-routes=${data.terraform_remote_state.network.outputs.vpc_cidr_block} \
      --accept-routes \
      --ssh
  EOF
}

module "project02_was01_ec2" {
  source               = "../../../modules/ec2"
  instance_type        = "t3.micro"
  subnet_id            = data.terraform_remote_state.network.outputs.private_subnet_was_id
  security_group_ids   = [data.terraform_remote_state.security.outputs.was_sg_id]
  key_name             = module.project02_was_ec2_key.key_name
  name                 = "project02-was01"
  iam_instance_profile = data.terraform_remote_state.security.outputs.ssm_instance_profile_name
}

module "project02_was02_ec2" {
  source               = "../../../modules/ec2"
  instance_type        = "t3.micro"
  subnet_id            = data.terraform_remote_state.network.outputs.private_subnet_was_id
  security_group_ids   = [data.terraform_remote_state.security.outputs.was_sg_id]
  key_name             = module.project02_was_ec2_key.key_name
  name                 = "project02-was02"
  iam_instance_profile = data.terraform_remote_state.security.outputs.ssm_instance_profile_name
}

module "project02_db_ec2" {
  source               = "../../../modules/ec2"
  instance_type        = "t3.micro"
  subnet_id            = data.terraform_remote_state.network.outputs.private_subnet_db_id
  security_group_ids   = [data.terraform_remote_state.security.outputs.db_sg_id]
  key_name             = module.project02_db_ec2_key.key_name
  name                 = "project02-db"
  iam_instance_profile = data.terraform_remote_state.security.outputs.ssm_instance_profile_name
}
