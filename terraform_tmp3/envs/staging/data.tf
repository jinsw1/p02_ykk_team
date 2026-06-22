# ../envs/staging/data.tf
############################################
# REMOTE STATE (infra 참조)
############################################
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "project02-infra-tfstate"
    key    = "infra/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

############################################
# DATA SOURCES
############################################
data "cloudflare_zones" "main" {
  name = var.domain_name
}

data "aws_acm_certificate" "wildcard" {
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
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
  zone_id              = data.cloudflare_zones.main.result[0].id
}