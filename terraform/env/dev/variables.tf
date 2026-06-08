# variables.tf

variable "region" {}
variable "az" {}
variable "project" {}
variable "vpc_cidr" {}

variable "public_subnet_proxy_cidr" {}
variable "public_subnet_nat_cidr" {}
variable "public_subnet_bastion_cidr" {}
variable "private_subnet_app_cidr" {}
variable "private_subnet_db_cidr" {}

variable "instance_type" {}
variable "key_name" {}
variable "public_key_path" {}
variable "mgmt_ip" {}
