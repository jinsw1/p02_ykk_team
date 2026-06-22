# ../envs/infra/providers.tf
############################################
# Providers + tfstate 저장
############################################
terraform {
  required_version = ">=1.14.0, <1.16.0"

  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 6.0" }
    tailscale  = { source = "tailscale/tailscale", version = "0.17.2" }
    cloudflare = { source = "cloudflare/cloudflare", version = "~> 5.0" }
    time       = { source = "hashicorp/time", version = "~> 0.9" }
  }

  # tfstate를 S3에 저장
  backend "s3" {
    bucket         = "project02-infra-tfstate"
    key            = "infra/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "project02-infra-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" { region = "ap-northeast-2" }

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = var.tailnet_name
}

provider "cloudflare" { api_token = var.cloudflare_api_token }
