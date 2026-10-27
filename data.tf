data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  count = var.enable_ec2_test_instance ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    sid     = "AllowEc2AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "app_access" {
  statement {
    sid       = "ListApplicationBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.app.arn]
  }

  statement {
    sid       = "ManageApplicationObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.app.arn}/*"]
  }

  dynamic "statement" {
    for_each = var.enable_ssm_parameters && length(var.ssm_parameters) > 0 ? [1] : []

    content {
      sid       = "ReadApplicationParameters"
      effect    = "Allow"
      actions   = ["ssm:GetParameter", "ssm:GetParameters"]
      resources = [for parameter in aws_ssm_parameter.app : parameter.arn]
    }
  }
}