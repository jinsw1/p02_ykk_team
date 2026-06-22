# ../envs/staging/compute.tf
############################################
# EC2 INSTANCES (WAS / DB)
############################################
module "stg_was01" {
  source               = "../../modules/ec2"
  instance_type        = "t3.micro"
  subnet_id            = module.project02_stg_private_subnet_was_a.subnet_id
  security_group_ids   = [module.stg_was_sg.sg_id]
  key_name             = "project02-was-key"
  iam_instance_profile = local.ssm_instance_profile
  name                 = "stg-was01"
  role                 = "was-staging"
  env                  = "staging"
}

module "stg_was02" {
  source               = "../../modules/ec2"
  instance_type        = "t3.micro"
  subnet_id            = module.project02_stg_private_subnet_was_b.subnet_id
  security_group_ids   = [module.stg_was_sg.sg_id]
  key_name             = "project02-was-key"
  iam_instance_profile = local.ssm_instance_profile
  name                 = "stg-was02"
  role                 = "was-staging"
  env                  = "staging"
}

module "stg_db" {
  source               = "../../modules/ec2"
  instance_type        = "t3.micro"
  subnet_id            = module.project02_stg_private_subnet_db.subnet_id
  security_group_ids   = [module.stg_db_sg.sg_id]
  key_name             = "project02-db-key"
  iam_instance_profile = local.ssm_instance_profile
  name                 = "stg-db"
  role                 = "db-staging"
  env                  = "staging"
}

############################################
# SSM PARAMETER STORE
############################################
resource "aws_ssm_parameter" "stg_db_host" {
  name  = "/staging/app/db/host"
  type  = "String"
  value = module.stg_db.private_ip

  lifecycle {
    ignore_changes = [value]
  }

  depends_on = [module.stg_db]
}