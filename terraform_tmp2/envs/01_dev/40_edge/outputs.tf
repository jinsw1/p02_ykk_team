
output "alb_arn" {
  value = module.project02_alb.alb_arn
}

output "alb_dns_name" {
  value = module.project02_alb.dns_name
}

output "acm_certificate_arn" {
  value = aws_acm_certificate_validation.this.certificate_arn
}

output "cloudflare_zone_id" {
  value = local.zone_id
}
