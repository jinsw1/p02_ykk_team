# variables.tf

variable "project" {
  type = string
}

variable "az" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_app_cidr" {
  type = string
}

variable "private_db_cidr" {
  type = string
}

variable "my_ip" {
  type = string
}

variable "key_name" {
  type = string
}

variable "nat_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "proxy_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "app_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "db_instance_type" {
  type    = string
  default = "t3.micro"
}
