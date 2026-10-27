resource "aws_security_group" "app" {
  name        = local.resource_names.security_group
  description = "Application demo security group; SSH is closed unless CIDRs are explicitly supplied."
  vpc_id      = data.aws_vpc.default.id
  tags        = local.common_tags

  dynamic "ingress" {
    for_each = var.allowed_cidr_blocks

    content {
      description = "SSH from explicitly approved CIDR ${ingress.value}"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}