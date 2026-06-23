# ../envs/infra/compute.tf
############################################
# DATA SOURCES (AMI)
############################################
data "aws_ami" "latest_al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

############################################
# KEYPAIR
############################################
module "project02_infra_ec2_key" {
  source   = "../../modules/keypair"
  key_name = "project02-infra-key"
}

############################################
# Infra INSTANCES
############################################
module "project02_infra_ec2" {
  source               = "../../modules/ec2"
  instance_type        = "t3.micro"
  subnet_id            = module.project02_private_subnet_infra.subnet_id
  security_group_ids   = [module.project02_infra_sg.sg_id]
  key_name             = module.project02_infra_ec2_key.key_name
  name                 = "project02-infra"
  #iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  iam_instance_profile = aws_iam_instance_profile.infra_profile.name
  
  role = "infra"
  env  = "infra"

  source_dest_check = false

  depends_on = [
	aws_instance.nat_instance,
  aws_route_table.private_rt
	]

  user_data = <<-EOF
    #!/bin/bash -eux

    echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
    echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
    sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

    until curl -s https://pkgs.tailscale.com >/dev/null; do sleep 5; done
    curl -fsSL https://tailscale.com/install.sh | sh
    systemctl enable --now tailscaled
    sysctl --system
    tailscale up \
      --auth-key=${tailscale_tailnet_key.ec2_join_key.key} \
      --hostname=project02 \
      --advertise-routes=${module.project02_vpc.cidr_block} \
      --accept-routes \
      --ssh
  EOF
}

############################################
# NAT INSTANCE
############################################
# NAT Instance (EC2 based NAT instead of NAT Gateway)
# → 비용 절감 / 학습용 구조
resource "aws_instance" "nat_instance" {
  ami                         = data.aws_ami.latest_al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = module.project02_public_subnet_nat.subnet_id
  associate_public_ip_address = true

  source_dest_check      = false # NAT 필수 설정
  vpc_security_group_ids = [aws_security_group.nat_sg.id]

  user_data = <<-EOF
  	#!/bin/bash -eux

    # NAT routing enable
    echo 1 > /proc/sys/net/ipv4/ip_forward

    # iptables NAT config
    dnf install -y iptables iptables-services
    systemctl enable --now iptables

    iptables -P FORWARD ACCEPT
    iptables -I FORWARD -j ACCEPT
    iptables -t nat -A POSTROUTING -s ${module.project02_vpc.cidr_block} -j MASQUERADE

    service iptables save
  EOF

  depends_on = [module.project02_igw]

  tags = {
    Name = "nat-instance"
  }
}

##탄력 아이피 적용시 주석제거
# resource "aws_eip" "nat" {
#   domain = "vpc"
# }
# resource "aws_eip_association" "nat" {
#   instance_id   = aws_instance.nat_instance.id
#   allocation_id = aws_eip.nat.id
# }