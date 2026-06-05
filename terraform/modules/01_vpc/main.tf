# ykk/modules/01_vpc/main.tf

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = { Name = "${var.project}-vpc" }
}


resource "aws_subnet" "public_proxy" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project}-public-subnet-proxy"}
}

resource "aws_subnet" "private_app" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_app_cidr
  availability_zone = var.az
  tags              = { Name = "${var.project}-private-app-subnet01" }
}

resource "aws_subnet" "private_db" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_db_cidr
  availability_zone = var.az
  tags              = { Name = "${var.project}-private-db-subnet"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id   = aws_vpc.vpc.id
  tags     = { Name = "${var.project}-igw" }
}


resource "aws_security_group" "nat" {
  name        = "${var.project}-nat-sg"
  vpc_id      = aws_vpc.vpc.id
  tags        = { Name = "${var.project}-nat-sg" }
}

# 인바운드 private 서브넷 전체
resource "aws_security_group_rule" "nat_ingress_from_private" {
  type              = "ingress"
  security_group_id = aws_security_group.nat.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.private_app_cidr, var.private_db_cidr]
  description       = "all traffic from private subnets"
}

# 아웃바운드 인터넷
resource "aws_security_group_rule" "nat_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.nat.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "all outbound to internet"
}


resource "aws_route_table" "public_rt" {
  vpc_id         = aws_vpc.vpc.id
  route {
    cidr_block   = "0.0.0.0/0"
    gateway_id   = aws_internet_gateway.igw.id
  }
  tags           = { Name = "${var.project}-rt" }
}

# public proxy subnet 과 rt 연결
resource "aws_route_table_association" "public_proxy" {
  subnet_id      = aws_subnet.public_proxy.id
  route_table_id = aws_route_table.public_rt.id
}