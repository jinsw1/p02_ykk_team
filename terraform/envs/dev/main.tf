
module "vpc" {
  source             = "../../modules/01_vpc"
  project            = var.project
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  private_app_cidr   = var.private_app_cidr
  private_db_cidr    = var.private_db_cidr
  az                 = var.az
}

module "sg" {
  source   = "../../modules/02_sg"
  project  = var.project
  vpc_id   = module.vpc.vpc_id
  my_ip    = var.my_ip
}


module "ec2" {
  source                = "../../modules/03_ec2"
  project               = var.project
  key_name              = var.key_name
  vpc_id                = module.vpc.vpc_id
  public_subnet_id      = module.vpc.public_subnet_id
  private_app_subnet_id = module.vpc.private_app_subnet_id
  private_db_subnet_id  = module.vpc.private_db_subnet_id
  nat_sg_id             = module.vpc.nat_sg_id
  proxy_sg_id           = module.sg.proxy_sg_id
  app_sg_id             = module.sg.app_sg_id
  db_sg_id              = module.sg.db_sg_id
  bastion_sg_id         = module.sg.bastion_sg_id
  nat_instance_type     = var.nat_instance_type
  proxy_instance_type   = var.proxy_instance_type
  app_instance_type     = var.app_instance_type
  db_instance_type      = var.db_instance_type
  bastion_instance_type = var.bastion_instance_type
}