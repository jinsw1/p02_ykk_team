# /modules/06_keypair/outputs.tf

output "key_name" {
  value = aws_key_pair.this.key_name
}
