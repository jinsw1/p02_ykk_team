# /modules/02_sg/main.tf

resource "aws_security_group" "this" {
  name   = "${var.project}-${var.name}-sg"
  vpc_id = var.vpc_id
  tags   = { Name = "${var.project}-${var.name}-sg" }
}
