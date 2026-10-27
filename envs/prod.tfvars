environment = "prod"
company     = "bjit"
project     = "tfassign"
aws_region  = "us-east-1"

enable_versioning         = true
enable_dynamodb           = true
enable_iam_role           = true
enable_ssm_parameters    = true
enable_cloudwatch_logs   = true
enable_lifecycle_rule    = true
enable_ec2_test_instance = false
ec2_free_tier_approved   = false
prevent_destroy          = true
lifecycle_expiration_days = 90

ssm_parameters = {
  app_name     = "terraform-training"
  log_level    = "WARN"
  feature_flag = "true"
}

log_groups = {
  app    = 30
  worker = 30
}

tags = {
  Owner       = "Your-name-here"
  CostCenter  = "training"
  ManagedBy   = "terraform"
  Environment = "prod"
  DataClass   = "internal"
}

allowed_cidr_blocks = []