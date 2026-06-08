# /modules/06_keypair/variables.tf

variable "key_name" {}
variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}
