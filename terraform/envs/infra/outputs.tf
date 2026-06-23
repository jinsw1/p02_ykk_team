# ../envs/infra/outputs.tf
############################################
# VPC
############################################
output "vpc_id" {
  value = module.project02_vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.project02_vpc.cidr_block
}

############################################
# SUBNETS
############################################
output "private_subnet_infra_id" {
  value = module.project02_private_subnet_infra.subnet_id
}

output "public_subnet_nat_id" {
  value = module.project02_public_subnet_nat.subnet_id
}

############################################
# NETWORK
############################################
output "igw_id" {
  value = module.project02_igw.igw_id
}

############################################
# SECURITY GROUPS
############################################
output "infra_sg_id" {
  value = module.project02_infra_sg.sg_id
}

output "nat_sg_id" {
  value = aws_security_group.nat_sg.id
}

############################################
# IAM
############################################
output "ssm_instance_profile_name" {
  value = aws_iam_instance_profile.ssm_profile.name
}

############################################
# EC2
############################################
output "infra_instance_id" {
  value = module.project02_infra_ec2.instance_id
}

output "nat_instance_id" {
  value = aws_instance.nat_instance.id
}

output "nat_public_ip" {
  value = aws_instance.nat_instance.public_ip
}

output "nat_eni_id" {
  value = aws_instance.nat_instance.primary_network_interface_id
}

############################################
# TAILSCALE
############################################
output "tailscale_device_id" {
  value = data.tailscale_device.my_ec2_device.id
}

############################################
# Ansible inventory (dev/staging/prod config.tf 에서 사용)
############################################
output "infra_private_ip" {
  value = module.project02_infra_ec2.private_ip
}

output "infra_key_name" {
  value = module.project02_infra_ec2_key.key_name
}