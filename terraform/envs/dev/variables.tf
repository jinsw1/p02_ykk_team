
variable "tailnet_name" {
  type = string
}

variable "tailscale_api_key" {
  type      = string
  sensitive = true
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "domain_name" {
  type = string
}