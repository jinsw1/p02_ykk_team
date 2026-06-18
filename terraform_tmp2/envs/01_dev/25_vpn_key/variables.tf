
variable "tailnet_name" {
  type = string
}

variable "tailscale_api_key" {
  type      = string
  sensitive = true
}
