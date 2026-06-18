
output "ec2_join_key" {
  value     = tailscale_tailnet_key.ec2_join_key.key
  sensitive = true
}
