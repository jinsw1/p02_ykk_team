# /modules/05_ec2/variables.tf

variable "project" {}
variable "name" {}
variable "ami_id" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "sg_ids" {}
variable "key_name" {}
variable "user_data" {
  default = null
}
variable "source_dest_check" {
  default = true
}
