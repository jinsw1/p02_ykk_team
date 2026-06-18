
############################################
# SECURITY GROUPS
############################################
output "infra_sg_id" {
  value = module.project02_infra_sg.sg_id
}

output "was_sg_id" {
  value = module.project02_was_sg.sg_id
}

output "db_sg_id" {
  value = module.project02_db_sg.sg_id
}

output "alb_sg_id" {
  value = module.project02_alb_sg.sg_id
}

############################################
# IAM (SSM)
############################################
output "ssm_role_arn" {
  value = aws_iam_role.ssm_role.arn
}

output "ssm_instance_profile_name" {
  value = aws_iam_instance_profile.ssm_profile.name
}
