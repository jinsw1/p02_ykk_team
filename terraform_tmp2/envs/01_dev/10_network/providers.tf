
terraform {
  required_version = ">=1.14.0, <1.16.0"

  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 6.0" }
  }

  # tfstate를 S3에 저장
  backend "s3" {
    bucket         = "project02-dev-tfstate"
    key            = "dev/10-network/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "project02-dev-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" { region = "ap-northeast-2" }
