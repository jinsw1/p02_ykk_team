
terraform {
  required_version = ">=1.14.0, <1.16.0"

  required_providers {
    tailscale = { source = "tailscale/tailscale", version = "0.17.2" }
    time      = { source = "hashicorp/time", version = "~> 0.11" }
  }

  # tfstate를 S3에 저장
  backend "s3" {
    bucket         = "project02-dev-tfstate"
    key            = "dev/45-vpn/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "project02-dev-tfstate-lock"
    encrypt        = true
  }
}

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = var.tailnet_name
}
