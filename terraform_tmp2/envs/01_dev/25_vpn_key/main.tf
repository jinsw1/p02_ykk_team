# ../25_vpn_key/main.tf
############################################
# TAILSCALE EC2 JOIN KEY
############################################
resource "tailscale_tailnet_key" "ec2_join_key" {
  reusable      = true
  ephemeral     = true
  preauthorized = true
  expiry        = 3600
}
