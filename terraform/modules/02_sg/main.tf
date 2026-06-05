# ykk/modules/02_sg/main.tf

# --------------- proxy ---------------
resource "aws_security_group" "proxy" {
  name   = "${var.project}-proxy-sg"
  vpc_id = var.vpc_id
  tags   = { Name = "${var.project}-proxy-sg" }
}

# 인바운드 -> bastion(22)
resource "aws_security_group_rule" "proxy_ingress_ssh_bastion" {
  type                     = "ingress"
  security_group_id        = aws_security_group.proxy.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
}

# 인바운드 HTTP(80)
resource "aws_security_group_rule" "proxy_ingress_http" {
  type              = "ingress"
  security_group_id = aws_security_group.proxy.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "http(80)"
}

# 인바운드 HTTPS(443)
resource "aws_security_group_rule" "proxy_ingress_https" {
  type              = "ingress"
  security_group_id = aws_security_group.proxy.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# 아웃바운드 app-sg (proxy -> app)
resource "aws_security_group_rule" "proxy_egress_to_app" {
  type                     = "egress"
  security_group_id        = aws_security_group.proxy.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
}


# --------------- app ---------------
resource "aws_security_group" "app" {
  name   = "${var.project}-app-sg"
  vpc_id = var.vpc_id
  tags   = { Name = "${var.project}-app-sg" }
}

# 인바운드 -> bastion(22)
resource "aws_security_group_rule" "app_ingress_ssh_bastion" {
  type                     = "ingress"
  security_group_id        = aws_security_group.app.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
}

# 인바운드 proxy-sg (proxy -> app)
resource "aws_security_group_rule" "app_ingress_from_proxy" {
  type                     = "ingress"
  security_group_id        = aws_security_group.app.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.proxy.id
}

# 아웃바운드 전체 허용 (NAT 경유 인터넷)
resource "aws_security_group_rule" "app_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.app.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}


# --------------- db ---------------
resource "aws_security_group" "db" {
  name   = "${var.project}-db-sg"
  vpc_id = var.vpc_id
  tags   = { Name = "${var.project}-db-sg" }
}

# 인바운드 -> bastion(22)
resource "aws_security_group_rule" "db_ingress_ssh_bastion" {
  type                     = "ingress"
  security_group_id        = aws_security_group.db.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
}

# 인바운드 app-sg (app -> db)
resource "aws_security_group_rule" "db_ingress_from_app" {
  type                     = "ingress"
  security_group_id        = aws_security_group.db.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
}

# 아웃바운드 전체 허용 (NAT 경유 인터넷)
resource "aws_security_group_rule" "db_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.db.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}


# --------------- bastion ---------------
resource "aws_security_group" "bastion" {
  name   = "${var.project}-bastion-sg"
  vpc_id = var.vpc_id
  tags   = { Name = "${var.project}-bastion-sg" }
}

resource "aws_security_group_rule" "bastion_ingress_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.bastion.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip]
}

resource "aws_security_group_rule" "bastion_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.bastion.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}