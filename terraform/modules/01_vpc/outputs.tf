# /modules/01_vpc/outputs.tf

output "vpc_id"               { value = aws_vpc.this.id }
output "public_subnet_id"     { value = aws_subnet.public_proxy.id }
output "private_app_subnet_id" { value = aws_subnet.private_app.id }
output "private_db_subnet_id"  { value = aws_subnet.private_db.id }
output "private_app_cidr"     { value = aws_subnet.private_app.cidr_block }
output "private_db_cidr"      { value = aws_subnet.private_db.cidr_block }
