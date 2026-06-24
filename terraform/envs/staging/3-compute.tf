# ../envs/dev/compute.tf
############################################
# KEYPAIR (SSH access per layer)
############################################
# module "project02_was_ec2_key" {
#   source   = "../../modules/keypair"
#   key_name = "project02-was-key"
# }
# module "project02_db_ec2_key" {
#   source   = "../../modules/keypair"
#   key_name = "project02-db-key"
# }

############################################
# EC2 INSTANCES (WAS / DB)
############################################
# WAS 1 (App server AZ-A)
module "project02_staging_was01_ec2" {
  source               = "../../modules/ec2"
  instance_type        = "t3.small"
  subnet_id            = module.project02_staging_private_subnet_was_a.subnet_id
  security_group_ids   = [module.project02_staging_was_sg.sg_id]
#  key_name             = module.project02_was_ec2_key.key_name
  key_name             = "project02-was-key"
  name                 = "project02-staging-was01"
  iam_instance_profile = local.ssm_instance_profile

  role = "was-staging"
  env  = "staging"
}

# WAS 2 (App server AZ-B)
module "project02_staging_was02_ec2" {
  source               = "../../modules/ec2"
  instance_type        = "t3.small"
  subnet_id            = module.project02_staging_private_subnet_was_b.subnet_id
  security_group_ids   = [module.project02_staging_was_sg.sg_id]
#  key_name             = module.project02_was_ec2_key.key_name
  key_name = "project02-was-key"
  name                 = "project02-staging-was02"
  iam_instance_profile = local.ssm_instance_profile

  role = "was-staging"
  env  = "staging"
}

# DB EC2 (PostgreSQL layer)
module "project02_staging_db_ec2" {
  source               = "../../modules/ec2"
  instance_type        = "t3.small"
  subnet_id            = module.project02_staging_private_subnet_db.subnet_id
  security_group_ids   = [module.project02_staging_db_sg.sg_id]
#   key_name             = module.project02_db_ec2_key.key_name
  key_name = "project02-db-key"
  name                 = "project02-staging-db"
  iam_instance_profile = local.ssm_instance_profile

  role = "db-staging"
  env  = "staging"
}

############################################
# SSM PARAMETER STORE (DB endpoint sharing)
############################################

resource "aws_ssm_parameter" "db_host" {
  name      = "/staging/app/db/host"
  type      = "String"
  value     = module.project02_staging_db_ec2.private_ip
  overwrite = true

  depends_on = [module.project02_staging_db_ec2]
}