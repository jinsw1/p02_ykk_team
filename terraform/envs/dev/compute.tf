# compute.tf

# NAT instance
module "nat" {
  source            = "../../modules/03_ec2"
  project           = var.project
  name              = "nat"
  instance_type     = var.nat_instance_type
  subnet_id         = module.vpc.public_subnet_id
  sg_id             = module.nat_sg.id
  source_dest_check = false
  user_data         = <<-EOF
    #!/bin/bash
    yum install -y iptables-services
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    service iptables save
    systemctl enable iptables
  EOF
}

# NAT private route table
resource "aws_route_table" "private" {
  vpc_id = module.vpc.vpc_id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = module.nat.primary_network_interface_id
  }
  tags = { Name = "${var.project}-private-rt" }
}

resource "aws_route_table_association" "private_app" {
  subnet_id      = module.vpc.private_app_subnet_id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db" {
  subnet_id      = module.vpc.private_db_subnet_id
  route_table_id = aws_route_table.private.id
}


# bastion
module "bastion" {
  source        = "../../modules/03_ec2"
  project       = var.project
  name          = "bastion"
  instance_type = var.bastion_instance_type
  subnet_id     = module.vpc.public_subnet_id
  sg_id         = module.bastion_sg.id
  key_name      = var.key_name
}


# proxy
module "proxy" {
  source        = "../../modules/03_ec2"
  project       = var.project
  name          = "proxy"
  instance_type = var.proxy_instance_type
  subnet_id     = module.vpc.public_subnet_id
  sg_id         = module.proxy_sg.id
  key_name      = var.key_name
}


# app
module "app" {
  source        = "../../modules/03_ec2"
  project       = var.project
  name          = "app"
  instance_type = var.app_instance_type
  subnet_id     = module.vpc.private_app_subnet_id
  sg_id         = module.app_sg.id
  key_name      = var.key_name
}


# db
module "db" {
  source        = "../../modules/03_ec2"
  project       = var.project
  name          = "db"
  instance_type = var.db_instance_type
  subnet_id     = module.vpc.private_db_subnet_id
  sg_id         = module.db_sg.id
  key_name      = var.key_name
}
