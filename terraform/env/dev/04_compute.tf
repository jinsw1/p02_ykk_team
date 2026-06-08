# 04_compute.tf

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

module "ec2_proxy" {
  source        = "../../modules/05_ec2"
  project       = var.project
  name          = "proxy"
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = module.subnet_public_proxy.subnet_id
  sg_ids        = [module.sg_proxy.sg_id]
  key_name      = module.keypair.key_name
}

module "ec2_bastion" {
  source        = "../../modules/05_ec2"
  project       = var.project
  name          = "bastion"
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = module.subnet_public_bastion.subnet_id
  sg_ids        = [module.sg_bastion.sg_id]
  key_name      = module.keypair.key_name
}

module "ec2_nat" {
  source            = "../../modules/05_ec2"
  project           = var.project
  name              = "nat"
  ami_id            = data.aws_ami.al2023.id
  instance_type     = var.instance_type
  subnet_id         = module.subnet_public_nat.subnet_id
  sg_ids            = [module.sg_nat.sg_id]
  key_name          = module.keypair.key_name
  source_dest_check = false
  user_data         = <<-EOF
    #!/bin/bash
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p
    yum install -y iptables-services
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    service iptables save
    systemctl enable iptables
  EOF
}

module "ec2_app" {
  source        = "../../modules/05_ec2"
  project       = var.project
  name          = "app"
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = module.subnet_private_app.subnet_id
  sg_ids        = [module.sg_app.sg_id]
  key_name      = module.keypair.key_name
}

module "ec2_db" {
  source        = "../../modules/05_ec2"
  project       = var.project
  name          = "db"
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = module.subnet_private_db.subnet_id
  sg_ids        = [module.sg_db.sg_id]
  key_name      = module.keypair.key_name
}
