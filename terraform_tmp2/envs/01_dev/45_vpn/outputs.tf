
output "tailscale_device_id" {
  value = data.tailscale_device.my_ec2_device.id
}

output "tailscale_device_ip" {
  value = data.tailscale_device.my_ec2_device.addresses[0]
}
