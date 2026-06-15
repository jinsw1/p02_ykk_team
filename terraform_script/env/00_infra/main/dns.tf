############################################
# DATA SOURCES
############################################
data "cloudflare_zones" "main" {
  name = var.domain_name
}

locals {
  zone_id = data.cloudflare_zones.main.result[0].id
}


############################################
# CLOUDFLARE DNS – www → ALB DNS
############################################
module "project02_dns" {
  source  = "../../../modules/cloudflare-dns"
  zone_id = local.zone_id

  name    = "www"
  type    = "CNAME"
  content = module.project02_alb.dns_name
  proxied = true
}
