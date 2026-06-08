# 06_outputs.tf

output "proxy_public_ip" {
  value = module.ec2_proxy.public_ip
}

output "bastion_public_ip" {
  value = module.ec2_bastion.public_ip
}

output "nat_public_ip" {
  value = module.ec2_nat.public_ip
}

output "app_private_ip" {
  value = module.ec2_app.private_ip
}

output "db_private_ip" {
  value = module.ec2_db.private_ip
}
