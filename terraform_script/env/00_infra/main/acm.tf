############################################
# ACM 인증서 & DNS 검증 (Cloudflare)
############################################
module "project02_acm" {
  source      = "../../../modules/acm"
  domain_name = var.domain_name
}

locals {
  # domain_validation_options 는 set(object) 타입이라
  # tolist() 으로 바꿔야 인덱스 접근이 됩니다.
  dv = tolist(module.project02_acm.domain_validation_options)[0]
}

module "project02_acm_dns" {
  source  = "../../../modules/cloudflare-dns"
  zone_id = local.zone_id

  # tolist() 후 0 번째 요소의 각 필드를 꺼내 쓴다
  name    = local.dv.resource_record_name
  type    = local.dv.resource_record_type
  content = local.dv.resource_record_value

  proxied = false
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = module.project02_acm.cert_arn
  validation_record_fqdns = [module.project02_acm_dns.fqdn]
}