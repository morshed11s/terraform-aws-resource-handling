variable "environment" {
  description = "Deployment environment selected by the tfvars file."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "company" {
  description = "Lowercase company identifier used in resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,14}$", var.company))
    error_message = "Company must be lowercase, start with a letter or number, and contain at most 15 letters, numbers, or hyphens."
  }
}

variable "project" {
  description = "Lowercase project identifier used in resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,14}$", var.project))
    error_message = "Project must be lowercase, start with a letter or number, and contain at most 15 letters, numbers, or hyphens."
  }
}

variable "aws_region" {
  description = "AWS region. The supported regions have a short-name mapping in locals.tf."
  type        = string

  validation {
    condition     = contains(["us-east-1", "us-east-2", "us-west-2"], var.aws_region)
    error_message = "Use a region with a configured short name: us-east-1, us-east-2, or us-west-2."
  }
}

variable "tags" {
  description = "Additional project tags. Required production tags are validated here."
  type        = map(string)

  validation {
    condition     = alltrue([for key, value in var.tags : length(trimspace(key)) > 0 && length(trimspace(value)) > 0])
    error_message = "Tag keys and values must not be empty."
  }

  validation {
    condition = var.environment != "prod" || (
      lookup(var.tags, "Environment", "") == "prod" &&
      lookup(var.tags, "DataClass", "") == "internal" &&
      length(trimspace(lookup(var.tags, "Owner", ""))) > 0 &&
      length(trimspace(lookup(var.tags, "CostCenter", ""))) > 0 &&
      length(trimspace(lookup(var.tags, "ManagedBy", ""))) > 0
    )
    error_message = "Production tags must include Owner, CostCenter, ManagedBy, Environment=prod, and DataClass=internal."
  }
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning. Dev must be unversioned; staging and prod must be versioned."
  type        = bool

  validation {
    condition     = var.enable_versioning == (var.environment != "dev")
    error_message = "S3 versioning must be disabled in dev and enabled in staging and prod."
  }
}

variable "enable_dynamodb" {
  description = "Create the PAY_PER_REQUEST DynamoDB configuration table."
  type        = bool
  default     = true
}

variable "enable_iam_role" {
  description = "Create the least-privilege demo IAM role and policy."
  type        = bool
  default     = true
}

variable "enable_ssm_parameters" {
  description = "Create standard-tier SSM String parameters."
  type        = bool
  default     = true
}

variable "enable_cloudwatch_logs" {
  description = "Create CloudWatch log groups."
  type        = bool
  default     = true
}

variable "enable_lifecycle_rule" {
  description = "Expire current S3 objects after lifecycle_expiration_days."
  type        = bool
  default     = true
}

variable "lifecycle_expiration_days" {
  description = "Number of days before current S3 objects expire."
  type        = number

  validation {
    condition     = var.lifecycle_expiration_days >= 1 && var.lifecycle_expiration_days <= 3650 && floor(var.lifecycle_expiration_days) == var.lifecycle_expiration_days
    error_message = "Lifecycle expiration must be a whole number from 1 through 3650 days."
  }
}

variable "prevent_destroy" {
  description = "Assignment intent flag. Terraform lifecycle.prevent_destroy cannot be driven by an input variable; see README."
  type        = bool

  validation {
    condition     = var.prevent_destroy == (var.environment == "prod")
    error_message = "prevent_destroy must be false for dev/staging and true for prod (intent flag; see Terraform lifecycle limitation in README)."
  }
}

variable "ssm_parameters" {
  description = "Map of simple SSM String parameter keys to values. Do not place secrets here."
  type        = map(string)

  validation {
    condition     = alltrue([for key, value in var.ssm_parameters : can(regex("^[A-Za-z0-9_.-]+$", key)) && length(value) > 0 && length(value) <= 4096])
    error_message = "SSM keys may contain letters, numbers, underscores, periods, or hyphens; values must be 1-4096 characters."
  }
}

variable "log_groups" {
  description = "Map of CloudWatch log group suffixes to retention days."
  type        = map(number)

  validation {
    condition     = alltrue([for key, days in var.log_groups : can(regex("^[A-Za-z0-9_.-]+$", key)) && contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], days)])
    error_message = "Log group keys must be simple names and retention must use an AWS-supported number of days."
  }
}

variable "allowed_cidr_blocks" {
  description = "Optional IPv4 CIDRs allowed to connect to TCP/22 on the demo security group. Empty by default."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.allowed_cidr_blocks : can(cidrnetmask(cidr))])
    error_message = "Every allowed_cidr_blocks value must be a valid IPv4 CIDR range."
  }
}

variable "enable_ec2_test_instance" {
  description = "Optional dev-only EC2 test instance. Disabled by default and may incur charges."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_ec2_test_instance || var.environment == "dev"
    error_message = "EC2 test instance is permitted only in dev."
  }
}

variable "ec2_free_tier_approved" {
  description = "Explicit acknowledgement that the AWS account has applicable free-tier approval before enabling EC2."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_ec2_test_instance || var.ec2_free_tier_approved
    error_message = "Set ec2_free_tier_approved=true only after confirming account eligibility and expected charges."
  }
}