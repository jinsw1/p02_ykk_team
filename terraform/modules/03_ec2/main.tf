# ykk/modules/03_ec2/main.tf

# Amazon Linux 2023 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# --------------- NAT ---------------
resource "aws_instance" "nat" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.nat_instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.nat_sg_id]
  source_dest_check      = false
  tags                   = { Name = "${var.project}-nat-instance" }

  user_data = <<-EOF
    #!/bin/bash
    # iptables-services 먼저 설치
    yum install -y iptables-services

    # ip_forward 영속화
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p

    # iptables 규칙 적용
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

    # 규칙 저장 및 부팅 시 자동 로드 설정
    service iptables save
    systemctl enable iptables
  EOF
}

# NAT - Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat.primary_network_interface_id
  }
  tags = { Name = "${var.project}-private-rt" }
}

resource "aws_route_table_association" "private_app" {
  subnet_id      = var.private_app_subnet_id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_db" {
  subnet_id      = var.private_db_subnet_id
  route_table_id = aws_route_table.private_rt.id
}


# --------------- proxy ---------------
resource "aws_instance" "proxy" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.proxy_instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.proxy_sg_id]
  key_name               = var.key_name
  tags                   = { Name = "${var.project}-proxy" }
}


# --------------- app ---------------
resource "aws_instance" "app" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.app_instance_type
  subnet_id              = var.private_app_subnet_id
  vpc_security_group_ids = [var.app_sg_id]
  key_name               = var.key_name
  tags                   = { Name = "${var.project}-app" }
}


# --------------- db ---------------
resource "aws_instance" "db" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.db_instance_type
  subnet_id              = var.private_db_subnet_id
  vpc_security_group_ids = [var.db_sg_id]
  key_name               = var.key_name
  tags                   = { Name = "${var.project}-db" }
}


# --------------- bastion ---------------
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.bastion_instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.bastion_sg_id]
  key_name               = var.key_name
  tags                   = { Name = "${var.project}-bastion" }
}