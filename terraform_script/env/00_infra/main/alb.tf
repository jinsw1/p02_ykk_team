############################################
# APPLICATION LOAD BALANCER (ALB) 생성
############################################
module "project02_alb" {
  source = "../../../modules/alb"
  name   = "project02-alb"
  vpc_id = module.project02_vpc.vpc_id
  subnets = [
    module.project02_public_subnet_alb_a.subnet_id,
    module.project02_public_subnet_alb_b.subnet_id
  ]
  security_groups = [module.project02_alb_sg.sg_id]
}

# WAS1 / WAS2를 Target Group에 붙입니다
resource "aws_lb_target_group_attachment" "tg_was1" {
  target_group_arn = module.project02_alb.tg_arn
  target_id        = module.project02_was01_ec2.instance_id
  port             = 80
}
resource "aws_lb_target_group_attachment" "tg_was2" {
  target_group_arn = module.project02_alb.tg_arn
  target_id        = module.project02_was02_ec2.instance_id
  port             = 80
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
