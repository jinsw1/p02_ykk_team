# ../10_network/main.tf
############################################
# 01. DATA SOURCES (AMI/AZ)
############################################
data "aws_ami" "latest_al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

data "aws_availability_zones" "available" { state = "available" }

############################################
# 02. VPC/IGW
############################################
module "project02_vpc" {
  source     = "../../../modules/vpc"
  cidr_block = "10.0.0.0/16"
  name       = "project02-vpc"
}

module "project02_igw" {
  source = "../../../modules/internet-gateway"
  vpc_id = module.project02_vpc.vpc_id
  name   = "project02-igw"
}

############################################
# 03. SUBNETS (Private: infra/was/db, Public: nat/alb-a/alb-b)
############################################
module "project02_private_subnet_infra" {
  source        = "../../../modules/subnet"
  vpc_id        = module.project02_vpc.vpc_id
  cidr_block    = "10.0.10.0/24"
  az            = data.aws_availability_zones.available.names[0]
  map_public_ip = false
  name          = "project02-private-infra"
}

module "project02_private_subnet_was" {
  source        = "../../../modules/subnet"
  vpc_id        = module.project02_vpc.vpc_id
  cidr_block    = "10.0.20.0/24"
  az            = data.aws_availability_zones.available.names[0]
  map_public_ip = false
  name          = "project02-private-was"
}

module "project02_private_subnet_db" {
  source        = "../../../modules/subnet"
  vpc_id        = module.project02_vpc.vpc_id
  cidr_block    = "10.0.30.0/24"
  az            = data.aws_availability_zones.available.names[0]
  map_public_ip = false
  name          = "project02-private-db"
}

module "project02_public_subnet_nat" {
  source        = "../../../modules/subnet"
  vpc_id        = module.project02_vpc.vpc_id
  cidr_block    = "10.0.1.0/24"
  az            = data.aws_availability_zones.available.names[0]
  map_public_ip = true
  name          = "project02-public-nat"
}

module "project02_public_subnet_alb_a" {
  source        = "../../../modules/subnet"
  vpc_id        = module.project02_vpc.vpc_id
  cidr_block    = "10.0.2.0/24"
  az            = data.aws_availability_zones.available.names[0]
  map_public_ip = true
  name          = "project02-public-alb-a"
}

module "project02_public_subnet_alb_b" {
  source        = "../../../modules/subnet"
  vpc_id        = module.project02_vpc.vpc_id
  cidr_block    = "10.0.3.0/24"
  az            = data.aws_availability_zones.available.names[1]
  map_public_ip = true
  name          = "project02-public-alb-b"
}

############################################
# 04. NAT INSTANCE
############################################
resource "aws_security_group" "nat_sg" {
  vpc_id = module.project02_vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.project02_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nat_instance" {
  ami                         = data.aws_ami.latest_al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = module.project02_public_subnet_nat.subnet_id
  associate_public_ip_address = true

  source_dest_check      = false
  vpc_security_group_ids = [aws_security_group.nat_sg.id]

  user_data = <<-EOF
    #!/bin/bash -eux
    echo 1 > /proc/sys/net/ipv4/ip_forward
    dnf install -y iptables iptables-services
    systemctl enable --now iptables
    iptables -P FORWARD ACCEPT
    iptables -I FORWARD -j ACCEPT
    iptables -t nat -A POSTROUTING -s ${module.project02_vpc.cidr_block} -j MASQUERADE
    service iptables save
  EOF

  depends_on = [module.project02_igw]
  tags       = { Name = "nat-instance" }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_eip_association" "nat" {
  instance_id   = aws_instance.nat_instance.id
  allocation_id = aws_eip.nat.id
}

############################################
# 05. ROUTE TABLES
############################################
# Public RT
resource "aws_route_table" "public_rt" {
  vpc_id = module.project02_vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.project02_igw.igw_id
  }
}

resource "aws_route_table_association" "public_nat_rt" {
  subnet_id      = module.project02_public_subnet_nat.subnet_id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "alb_a" {
  subnet_id      = module.project02_public_subnet_alb_a.subnet_id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "alb_b" {
  subnet_id      = module.project02_public_subnet_alb_b.subnet_id
  route_table_id = aws_route_table.public_rt.id
}

# Private RT → NAT 인스턴스
resource "aws_route_table" "private_rt" {
  vpc_id = module.project02_vpc.vpc_id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat_instance.primary_network_interface_id
  }
}
resource "aws_route_table_association" "infra_rt" {
  subnet_id      = module.project02_private_subnet_infra.subnet_id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "was_rt" {
  subnet_id      = module.project02_private_subnet_was.subnet_id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "db_rt" {
  subnet_id      = module.project02_private_subnet_db.subnet_id
  route_table_id = aws_route_table.private_rt.id
}
