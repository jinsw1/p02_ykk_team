# ykk/modules/01_vpc/outputs.tf

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_proxy.id
}

output "private_app_subnet_id" {
  value = aws_subnet.private_app.id
}

output "private_db_subnet_id" {
  value = aws_subnet.private_db.id
}

output "nat_sg_id" {
  value = aws_security_group.nat.id
}