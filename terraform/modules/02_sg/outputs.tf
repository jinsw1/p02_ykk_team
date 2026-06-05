# ykk/modules/02_sg/outputs.tf

output "proxy_sg_id" {
  value = aws_security_group.proxy.id
}

output "app_sg_id" {
  value = aws_security_group.app.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}