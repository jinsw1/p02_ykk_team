# ykk/modules/03_ec2/outputs.tf

output "nat_instance_id" {
  value = aws_instance.nat.id
}

output "proxy_public_ip" {
  value = aws_instance.proxy.public_ip
}

output "app_private_ip" {
  value = aws_instance.app.private_ip
}

output "db_private_ip" {
  value = aws_instance.db.private_ip
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}