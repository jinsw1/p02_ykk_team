# /modules/04_sg/variables.tf

variable "project" {}
variable "name" {}
variable "vpc_id" {}

variable "ingress_rules" {
  type    = list(any)
  default = []
}

variable "egress_rules" {
  type    = list(any)
  default = []
}
