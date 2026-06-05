# /modules/01_vpc/variables.tf

variable "project"             { type = string }
variable "vpc_cidr"            { type = string }
variable "public_subnet_cidr"  { type = string }
variable "private_app_cidr"    { type = string }
variable "private_db_cidr"     { type = string }
variable "az"                  { type = string }
