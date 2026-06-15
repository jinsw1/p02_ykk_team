
############################################
# VARIABLES
############################################
variable "host_name" {
  type    = string
  default = "aws-ec2"
}

variable "tailnet_name" {
  type = string
}

variable "tailscale_auth_key" {
  type      = string
  sensitive = true
}

variable "tailscale_api_key" {
  type      = string
  sensitive = true
}

variable "domain_name" {
  type    = string
  default = "infrastudy.store"
}

variable "cloudflare_api_token" {
  type    = string
  default = ""
}

variable "cloudflare_zone_id" {
  type    = string
  default = ""
}