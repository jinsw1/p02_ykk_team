
############################################
# INFRA EC2
############################################
output "infra_instance_id" {
  value = module.project02_infra_ec2.instance_id
}

output "infra_private_ip" {
  value = module.project02_infra_ec2.private_ip
}

############################################
# WAS EC2 (01/02)
############################################
output "was01_instance_id" {
  value = module.project02_was01_ec2.instance_id
}

output "was01_private_ip" {
  value = module.project02_was01_ec2.private_ip
}

output "was02_instance_id" {
  value = module.project02_was02_ec2.instance_id
}

output "was02_private_ip" {
  value = module.project02_was02_ec2.private_ip
}

############################################
# DB EC2
############################################
output "db_instance_id" {
  value = module.project02_db_ec2.instance_id
}

output "db_private_ip" {
  value = module.project02_db_ec2.private_ip
}

############################################
# KEYPAIRS
############################################
output "infra_key_name" {
  value = module.project02_infra_ec2_key.key_name
}

output "was_key_name" {
  value = module.project02_was_ec2_key.key_name
}

output "db_key_name" {
  value = module.project02_db_ec2_key.key_name
}
