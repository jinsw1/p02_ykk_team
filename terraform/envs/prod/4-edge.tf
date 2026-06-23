# ../envs/dev/edge.tf
############################################
# DATA SOURCES (DNS Zone)
############################################
# Cloudflare Zone 조회
# → DNS record 생성 및 ACM validation에 필요
data "cloudflare_zones" "main" {
  name = var.domain_name
}

locals {
  # Cloudflare Zone ID 추출 (DNS record 생성에 필수)
  zone_id = data.cloudflare_zones.main.result[0].id
}

############################################
# ALB (Load Balancer layer)
############################################
module "project02_prod_alb" {
  source = "../../modules/alb"
  name   = "project02-prod-alb"
  vpc_id = local.vpc_id

  subnets = [
    module.project02_prod_public_subnet_alb_a.subnet_id,
    module.project02_prod_public_subnet_alb_b.subnet_id
  ]

  security_groups = [module.project02_prod_alb_sg.sg_id]
}

# Attach WAS instances to ALB target group
resource "aws_lb_target_group_attachment" "tg_was1" {
  target_group_arn = module.project02_prod_alb.tg_arn
  target_id        = module.project02_prod_was01_ec2.instance_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_was2" {
  target_group_arn = module.project02_prod_alb.tg_arn
  target_id        = module.project02_prod_was02_ec2.instance_id
  port             = 80
}

############################################
# ACM + DNS VALIDATION (HTTPS certificate)
############################################
module "project02_acm" {
  source      = "../../modules/acm"
  domain_name = var.domain_name
}

locals {
  # ACM validation record (DNS challenge)
  dv = tolist(module.project02_acm.domain_validation_options)[0]
}

# Cloudflare DNS record for ACM validation
module "project02_acm_dns" {
  source  = "../../modules/cloudflare-dns"
  zone_id = data.cloudflare_zones.main.result[0].id

  name    = local.dv.resource_record_name
  type    = local.dv.resource_record_type
  content = local.dv.resource_record_value

  proxied = false
}

# Final certificate validation
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = module.project02_acm.cert_arn
  validation_record_fqdns = [module.project02_acm_dns.fqdn]
}

############################################
# ALB LISTENER (HTTP → HTTPS redirect)
############################################

# HTTP redirect to HTTPS (security best practice)
resource "aws_lb_listener" "http" {
  load_balancer_arn = module.project02_prod_alb.alb_arn
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

# HTTPS listener (TLS termination at ALB)
resource "aws_lb_listener" "https" {
  load_balancer_arn = module.project02_prod_alb.alb_arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  certificate_arn = aws_acm_certificate_validation.this.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = module.project02_prod_alb.tg_arn
  }
}

############################################
# CLOUDFLARE DNS (public endpoint)
############################################

module "project02_dns" {
  source  = "../../modules/cloudflare-dns"
  zone_id = data.cloudflare_zones.main.result[0].id

  name    = "www"
  type    = "CNAME"
  content = module.project02_prod_alb.dns_name
  proxied = true
}