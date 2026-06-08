# terraform.tfvars

region   = "ap-northeast-2"
az       = "ap-northeast-2a"

project  = "ykk-project"
vpc_cidr = "10.0.0.0/16"

public_subnet_proxy_cidr   = "10.0.1.0/24"
public_subnet_nat_cidr     = "10.0.2.0/24"
public_subnet_bastion_cidr = "10.0.3.0/24"
private_subnet_app_cidr    = "10.0.10.0/24"
private_subnet_db_cidr     = "10.0.20.0/24"

instance_type   = "t3.micro"
key_name        = "ykk-project-key"
public_key_path = "~/.ssh/ykk-project-key.pub"

# mgmt ec2 ip 수정
mgmt_ip         = "3.36.51.145/32"
