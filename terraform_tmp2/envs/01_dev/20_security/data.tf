
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "project02-dev-tfstate"
    key    = "dev/10-network/terraform.tfstate"
    region = "ap-northeast-2"
  }
}
