resource "aws_ssm_parameter" "app" {
  for_each = var.enable_ssm_parameters ? var.ssm_parameters : {}

  name        = local.ssm_parameter_names[each.key]
  description = "Non-secret application configuration for ${var.environment}."
  type        = "String"
  tier        = "Standard"
  value       = each.value
  tags        = local.common_tags
}