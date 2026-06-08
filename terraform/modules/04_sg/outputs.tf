# /modules/04_sg/outputs.tf

output "sg_id" {
  value = aws_security_group.this.id
}
