
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

data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket = "project02-dev-tfstate"
    key    = "dev/30-compute/terraform.tfstate"
    region = "ap-northeast-2"
  }
}
