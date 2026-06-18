
terraform {
  required_version = ">=1.14.0, <1.16.0"

  required_providers {
    local = { source = "hashicorp/local", version = "~> 2.5" }
  }

  # tfstate를 S3에 저장
  backend "s3" {
    bucket         = "project02-dev-tfstate"
    key            = "dev/50-config/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "project02-dev-tfstate-lock"
    encrypt        = true
  }
}
