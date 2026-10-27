resource "aws_cloudwatch_log_group" "app" {
  for_each = var.enable_cloudwatch_logs ? var.log_groups : {}

  name              = local.log_group_names[each.key]
  retention_in_days = each.value
  tags              = local.common_tags
}