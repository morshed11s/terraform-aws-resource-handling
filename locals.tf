locals {
  env_short = {
    dev     = "dev"
    staging = "stg"
    prod    = "prd"
  }

  region_short = {
    us-east-1 = "use1"
    us-east-2 = "use2"
    us-west-2 = "usw2"
  }

  name_prefix = "${var.company}-${var.project}-${local.env_short[var.environment]}"
  region_code = local.region_short[var.aws_region]

  resource_names = {
    bucket       = "${local.name_prefix}-app-bucket-${local.region_code}"
    dynamodb     = "${local.name_prefix}-config-table-${local.region_code}"
    iam_role     = "${local.name_prefix}-app-role-${local.region_code}"
    iam_policy   = "${local.name_prefix}-app-policy-${local.region_code}"
    log_app      = "${local.name_prefix}-app-logs-${local.region_code}"
    log_worker   = "${local.name_prefix}-worker-logs-${local.region_code}"
    security_group = "${local.name_prefix}-app-sg-${local.region_code}"
    ec2_instance = "${local.name_prefix}-test-instance-${local.region_code}"
  }

  ssm_parameter_names = {
    for key in keys(var.ssm_parameters) : key => "/${var.project}/${var.environment}/${key}"
  }

  log_group_names = {
    for key in keys(var.log_groups) : key => "${local.name_prefix}-${key}-logs-${local.region_code}"
  }

  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  })
}