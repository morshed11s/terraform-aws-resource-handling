environment = "staging"
company     = "bjit"
project     = "tfassign"
owner       = "sumaiya"
student_id  = "30245"
aws_region  = "us-east-1"

enable_versioning         = true
enable_dynamodb           = true
enable_iam_role           = true
enable_ssm_parameters     = true
enable_cloudwatch_logs    = true
enable_lifecycle_rule     = true
enable_ec2_test_instance  = false
ec2_free_tier_approved    = false
prevent_destroy           = false
lifecycle_expiration_days = 30

ssm_parameters = {
  app_name     = "terraform-training"
  log_level    = "INFO"
  feature_flag = "true"
}

log_groups = {
  app    = 14
  worker = 14
}

tags = {
  CostCenter = "training"
  ManagedBy  = "terraform"
}

allowed_cidr_blocks = []