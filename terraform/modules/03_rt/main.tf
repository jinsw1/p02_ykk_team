# /modules/03_rt/main.tf

resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  dynamic "route" {
    for_each = var.gateway_id != null ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.gateway_id
    }
  }

  dynamic "route" {
    for_each = var.network_interface_id != null ? [1] : []
    content {
      cidr_block           = "0.0.0.0/0"
      network_interface_id = var.network_interface_id
    }
  }

  tags = { Name = var.name }
}

resource "aws_route_table_association" "this" {
  subnet_id      = var.subnet_id
  route_table_id = aws_route_table.this.id
}
