# ykk/modules/03_ec2/variables.tf

variable "project" {}
variable "key_name" {}

variable "vpc_id" {}
variable "public_subnet_id" {}
variable "private_app_subnet_id" {}
variable "private_db_subnet_id" {}
variable "nat_sg_id" {}

variable "bastion_sg_id" {}
variable "proxy_sg_id" {}
variable "app_sg_id" {}
variable "db_sg_id" {}

variable "nat_instance_type" {}
variable "proxy_instance_type" {}
variable "app_instance_type" {}
variable "db_instance_type" {}
variable "bastion_instance_type" {}
