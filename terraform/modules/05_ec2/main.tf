# /modules/05_ec2/main.tf

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.sg_ids
  key_name               = var.key_name
  source_dest_check      = var.source_dest_check
  user_data              = var.user_data
  tags                   = { Name = "${var.project}-${var.name}" }
}
