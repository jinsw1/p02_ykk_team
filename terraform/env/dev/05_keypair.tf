# 05_keypair.tf

module "keypair" {
  source          = "../../modules/06_keypair"
  key_name        = var.key_name
  public_key_path = var.public_key_path
}
