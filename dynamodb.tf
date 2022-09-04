variable "dynamodb_name" {
  description = "The name of the table, this needs to be unique within a region."
  type        = string
}

resource "aws_dynamodb_table" "lock_table" {
  name = var.dynamodb_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
    kms_key_arn = aws_kms_alias.remote_state_key.target_key_arn
  }

  lifecycle {
    prevent_destroy = true
  }
  tags = local.tags
}

resource "aws_iam_policy" "remote_lock" {
  description = "Policy for terraform state lock table"
  name = "${var.iam_policy_prefix}-dynamodb"
  path = local.iam_path
  policy = data.aws_iam_policy_document.remote_lock.json
  
  tags = local.tags
}
data "aws_iam_policy_document" "remote_lock" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable"
    ]
    resources = [
      aws_dynamodb_table.lock_table.arn
    ]
  }
}

output "dynamodb_iam_policy_arn" {
  value = aws_iam_policy.remote_lock.arn
}
