# /modules/02_subnet/outputs.tf

output "subnet_id" {
  value = aws_subnet.this.id
}
