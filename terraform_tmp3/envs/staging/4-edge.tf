# ../envs/staging/edge.tf
############################################
# ALB
############################################
module "stg_alb" {
  source = "../../modules/alb"
  name   = "stg-alb"
  vpc_id = local.vpc_id

  subnets = [
    module.project02_stg_public_subnet_alb_a.subnet_id,
    module.project02_stg_public_subnet_alb_b.subnet_id
  ]

  security_groups = [module.stg_alb_sg.sg_id]
}

resource "aws_lb_target_group_attachment" "stg_was1" {
  target_group_arn = module.stg_alb.tg_arn
  target_id        = module.stg_was01.instance_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "stg_was2" {
  target_group_arn = module.stg_alb.tg_arn
  target_id        = module.stg_was02.instance_id
  port             = 80
}

############################################
# ALB LISTENER
############################################
resource "aws_lb_listener" "stg_http" {
  load_balancer_arn = module.stg_alb.alb_arn
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

resource "aws_lb_listener" "stg_https" {
  load_balancer_arn = module.stg_alb.alb_arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.wildcard.arn

  default_action {
    type             = "forward"
    target_group_arn = module.stg_alb.tg_arn
  }
}

############################################
# CLOUDFLARE DNS
############################################
module "stg_dns" {
  source  = "../../modules/cloudflare-dns"
  zone_id = local.zone_id
  name    = "staging"
  type    = "CNAME"
  content = module.stg_alb.dns_name
  proxied = true
}