
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "project02-dev-tfstate"
    key    = "dev/10-network/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

data "terraform_remote_state" "security" {
  backend = "s3"
  config = {
    bucket = "project02-dev-tfstate"
    key    = "dev/20-security/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

data "terraform_remote_state" "vpn_key" {
  backend = "s3"
  config = {
    bucket = "project02-dev-tfstate"
    key    = "dev/25-vpn-key/terraform.tfstate"
    region = "ap-northeast-2"
  }
}
