output "environment" {
  description = "Environment selected by the active tfvars file."
  value       = var.environment
}

output "s3_bucket_name" {
  description = "Application bucket name."
  value       = aws_s3_bucket.app.bucket
}

output "s3_bucket_arn" {
  description = "Application bucket ARN."
  value       = aws_s3_bucket.app.arn
}

output "dynamodb_table_name" {
  description = "Configuration table name, or null when disabled."
  value       = try(aws_dynamodb_table.config[0].name, null)
}

output "iam_role_arn" {
  description = "Demo role ARN, or null when disabled."
  value       = try(aws_iam_role.app[0].arn, null)
}

output "ssm_parameter_names" {
  description = "Created SSM parameter names, empty when disabled."
  value       = { for key, parameter in aws_ssm_parameter.app : key => parameter.name }
}

output "cloudwatch_log_group_names" {
  description = "Created CloudWatch log group names, empty when disabled."
  value       = { for key, group in aws_cloudwatch_log_group.app : key => group.name }
}

output "security_group_id" {
  description = "Demo security group ID."
  value       = aws_security_group.app.id
}

output "ec2_instance_id" {
  description = "Optional test instance ID, or null when disabled."
  value       = try(aws_instance.test[0].id, null)
}