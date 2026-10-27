resource "aws_dynamodb_table" "config" {
  count        = var.enable_dynamodb ? 1 : 0
  name         = local.resource_names.dynamodb
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = local.common_tags
}