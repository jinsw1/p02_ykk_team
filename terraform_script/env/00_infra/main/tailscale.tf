############################################
# TAILSCALE EC2 JOIN KEY
############################################
resource "tailscale_tailnet_key" "ec2_join_key" {
  reusable      = true
  ephemeral     = true
  preauthorized = true
  expiry        = 3600
}


############################################
# TAILSCALE ROUTE 승인
############################################
resource "time_sleep" "wait_for_tailscale_sync" {
  depends_on      = [module.project02_infra_ec2]
  create_duration = "180s"
}

data "tailscale_device" "my_ec2_device" {
  hostname   = "project02"
  wait_for   = "300s"
  depends_on = [time_sleep.wait_for_tailscale_sync]
}

resource "tailscale_device_subnet_routes" "approve_vpc_routes" {
  device_id = data.tailscale_device.my_ec2_device.id
  routes    = [module.project02_vpc.cidr_block]
}
