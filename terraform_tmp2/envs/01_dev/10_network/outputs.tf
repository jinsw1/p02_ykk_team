
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
# PRIVATE SUBNETS
############################################
output "private_subnet_infra_id" {
  value = module.project02_private_subnet_infra.subnet_id
}

output "private_subnet_was_id" {
  value = module.project02_private_subnet_was.subnet_id
}

output "private_subnet_db_id" {
  value = module.project02_private_subnet_db.subnet_id
}

############################################
# PUBLIC SUBNETS
############################################
output "public_subnet_nat_id" {
  value = module.project02_public_subnet_nat.subnet_id
}

output "public_subnet_alb_a_id" {
  value = module.project02_public_subnet_alb_a.subnet_id
}

output "public_subnet_alb_b_id" {
  value = module.project02_public_subnet_alb_b.subnet_id
}

############################################
# NAT INSTANCE
############################################
output "nat_instance_id" {
  value = aws_instance.nat_instance.id
}

output "nat_instance_private_ip" {
  value = aws_instance.nat_instance.private_ip
}

output "nat_sg_id" {
  value = aws_security_group.nat_sg.id
}

############################################
# ROUTE TABLES
############################################
output "public_rt_id" {
  value = aws_route_table.public_rt.id
}

output "private_rt_id" {
  value = aws_route_table.private_rt.id
}
