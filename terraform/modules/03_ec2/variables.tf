# /modules/03_ec2/variables.tf

variable "project"           { type = string }
variable "name"              { type = string }
variable "instance_type"     { type = string }
variable "subnet_id"         { type = string }
variable "sg_id"             { type = string }
variable "key_name" {
  type    = string
  default = null
}
variable "source_dest_check" {
  type    = bool
  default = true
}
variable "user_data" {
  type    = string
  default = null
}