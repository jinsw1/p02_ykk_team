# /modules/02_subnet/variables.tf

variable "vpc_id" {}
variable "cidr_block" {}
variable "az" {}
variable "map_public_ip" {
  default = false
}
variable "name" {}
