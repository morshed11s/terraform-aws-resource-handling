environment = "dev"
company     = "bjit"
project     = "tfassign"
aws_region  = "us-east-1"

enable_versioning         = false
enable_dynamodb           = true
enable_iam_role           = true
enable_ssm_parameters    = true
enable_cloudwatch_logs   = true
enable_lifecycle_rule    = true
enable_ec2_test_instance = false
ec2_free_tier_approved   = false
prevent_destroy          = false
lifecycle_expiration_days = 7

ssm_parameters = {
  app_name     = "terraform-training"
  log_level    = "INFO"
  feature_flag = "true"
}

log_groups = {
  app    = 7
  worker = 7
}

tags = {
  Owner      = "Your-name-here"
  CostCenter = "training"
  ManagedBy  = "terraform"
}

allowed_cidr_blocks = []