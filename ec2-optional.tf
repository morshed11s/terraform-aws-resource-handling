data "aws_ami" "amazon_linux" {
  count       = var.enable_ec2_test_instance ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "test" {
  count                       = var.enable_ec2_test_instance ? 1 : 0
  ami                         = data.aws_ami.amazon_linux[0].id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnets.default[0].ids[0]
  vpc_security_group_ids      = [aws_security_group.app.id]
  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = merge(local.common_tags, {
    Name = local.resource_names.ec2_instance
  })
}