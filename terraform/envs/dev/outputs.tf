
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_public_proxy_id" {
  value = module.vpc.public_subnet_id
}

output "subnet_private_app_id" {
  value = module.vpc.private_app_subnet_id
}

output "subnet_private_db_id" {
  value = module.vpc.private_db_subnet_id
}

output "sg_proxy_id" {
  value = module.sg.proxy_sg_id
}

output "sg_app_id" {
  value = module.sg.app_sg_id
}

output "sg_db_id" {
  value = module.sg.db_sg_id
}

output "sg_bastion_id" {
  value = module.sg.bastion_sg_id
}

output "nat_instance_id" {
  value = module.ec2.nat_instance_id
}

output "bastion_public_ip" {
  value = module.ec2.bastion_public_ip
}

output "app_private_ip" {
  value = module.ec2.app_private_ip
}