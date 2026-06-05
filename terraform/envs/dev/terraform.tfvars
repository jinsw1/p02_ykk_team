# terraform.tfvars

project             = "ykk"
az                  = "ap-northeast-2a"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_app_cidr    = "10.0.10.0/24"
private_db_cidr     = "10.0.20.0/24"

# mgmt ip
my_ip               = "0.0.0.0/32"

# bastion pem key
key_name            = "ykk_key"

nat_instance_type     = "t3.micro"
bastion_instance_type = "t3.micro"
proxy_instance_type   = "t3.micro"
app_instance_type     = "t3.micro"
db_instance_type      = "t3.micro"
