# ../45_vpn/main.tf
############################################
# TAILSCALE JOIN 대기
############################################
# 30_compute에서 infra EC2가 생성된 직후, 그 안에서 tailscale up이
# 완료되어 tailnet에 join하기까지 시간을 위해 대기한 뒤에 조회 시도
resource "time_sleep" "wait_for_tailscale_sync" {
  create_duration = "180s"
}

############################################
# TAILSCALE DEVICE 조회, 승인
############################################
data "tailscale_device" "my_ec2_device" {
  hostname   = "project02"
  wait_for   = "300s"
  depends_on = [time_sleep.wait_for_tailscale_sync]
}

resource "tailscale_device_subnet_routes" "approve_vpc_routes" {
  device_id = data.tailscale_device.my_ec2_device.id
  routes    = [data.terraform_remote_state.network.outputs.vpc_cidr_block]
}
