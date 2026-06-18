# ../40_edge/main.tf
############################################
# DATA SOURCES (CF ZONE)
############################################
data "cloudflare_zones" "main" {
  name = var.domain_name
}

locals {
  zone_id = data.cloudflare_zones.main.result[0].id
}

############################################
# APPLICATION LOAD BALANCER (ALB) 생성
############################################
module "project02_alb" {
  source = "../../../modules/alb"
  name   = "project02-alb"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  subnets = [
    data.terraform_remote_state.network.outputs.public_subnet_alb_a_id,
    data.terraform_remote_state.network.outputs.public_subnet_alb_b_id
  ]
  security_groups = [data.terraform_remote_state.security.outputs.alb_sg_id]
}

# WAS1 / WAS2를 Target Group에 붙입니다
resource "aws_lb_target_group_attachment" "tg_was1" {
  target_group_arn = module.project02_alb.tg_arn
  target_id        = data.terraform_remote_state.compute.outputs.was01_instance_id
  port              = 80
}

resource "aws_lb_target_group_attachment" "tg_was2" {
  target_group_arn = module.project02_alb.tg_arn
  target_id        = data.terraform_remote_state.compute.outputs.was02_instance_id
  port              = 80
}

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

############################################
# ALB 리스너 (HTTP→HTTPS / HTTPS→Target Group)
############################################
resource "aws_lb_listener" "http" {
  load_balancer_arn = module.project02_alb.alb_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = module.project02_alb.alb_arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  certificate_arn = aws_acm_certificate_validation.this.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = module.project02_alb.tg_arn
  }
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
