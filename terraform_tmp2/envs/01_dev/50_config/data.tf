
data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket = "project02-dev-tfstate"
    key    = "dev/30-compute/terraform.tfstate"
    region = "ap-northeast-2"
  }
}
