resource "aws_iam_role" "app" {
  count              = var.enable_iam_role ? 1 : 0
  name               = local.resource_names.iam_role
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
  description        = "Least-privilege demo role for the ${var.project} ${var.environment} application."
  tags               = local.common_tags
}

resource "aws_iam_policy" "app" {
  count       = var.enable_iam_role ? 1 : 0
  name        = local.resource_names.iam_policy
  description = "Scoped access to this environment's application bucket and SSM parameters."
  policy      = data.aws_iam_policy_document.app_access.json
  tags        = local.common_tags
}

resource "aws_iam_role_policy_attachment" "app" {
  count      = var.enable_iam_role ? 1 : 0
  role       = aws_iam_role.app[0].name
  policy_arn = aws_iam_policy.app[0].arn
}