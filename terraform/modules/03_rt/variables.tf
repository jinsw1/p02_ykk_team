# /modules/03_rt/variables.tf

variable "vpc_id" {}
variable "subnet_id" {}
variable "name" {}
variable "gateway_id" {
  default = null
}
variable "network_interface_id" {
  default = null
}
