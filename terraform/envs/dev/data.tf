# ../envs/dev/data.tf
############################################
# Remote state (infra 참조)
############################################
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "project02-ykk-infra-tfstate"
    key    = "infra/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

############################################
# Infra outputs 참조 값
############################################
locals {
  vpc_id               = data.terraform_remote_state.infra.outputs.vpc_id
  vpc_cidr_block       = data.terraform_remote_state.infra.outputs.vpc_cidr_block
  igw_id               = data.terraform_remote_state.infra.outputs.igw_id
  nat_eni_id           = data.terraform_remote_state.infra.outputs.nat_eni_id
  ssm_instance_profile = data.terraform_remote_state.infra.outputs.ssm_instance_profile_name
  infra_sg_id          = data.terraform_remote_state.infra.outputs.infra_sg_id
  infra_private_ip = data.terraform_remote_state.infra.outputs.infra_private_ip
  infra_key_name   = data.terraform_remote_state.infra.outputs.infra_key_name
}