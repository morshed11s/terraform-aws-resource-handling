# Example only. Keep this block commented for local-state learning and dev.
# Before using a remote backend, create the S3 state bucket and lock table
# separately, then uncomment this block and run terraform init -migrate-state.
# Do not store credentials in this file.
#
# terraform {
#   backend "s3" {
#     bucket         = "replace-with-precreated-state-bucket"
#     key            = "tfassign/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "replace-with-precreated-lock-table"
#   }
# }