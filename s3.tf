resource "aws_s3_bucket" "app" {
  bucket = local.resource_names.bucket
  tags   = local.common_tags

  lifecycle {
    precondition {
      condition = var.environment != "prod" || (
        var.enable_versioning && var.enable_dynamodb && var.enable_iam_role &&
        var.enable_ssm_parameters && var.enable_cloudwatch_logs &&
        !var.enable_ec2_test_instance && var.prevent_destroy
      )
      error_message = "Prod requires versioning and all core services enabled, EC2 disabled, and the prevent_destroy intent flag set."
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket                  = aws_s3_bucket.app.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "app" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.app.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "app" {
  count  = var.enable_lifecycle_rule ? 1 : 0
  bucket = aws_s3_bucket.app.id

  dynamic "rule" {
    for_each = [1]

    content {
      id     = "expire-current-objects"
      status = "Enabled"

      filter {
        prefix = ""
      }

      expiration {
        days = var.lifecycle_expiration_days
      }
    }
  }
}