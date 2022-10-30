variable "key_name"{
  description = "The name the KMS key."
  type = string
  default = "terraform-key"
}
variable "organisation_name"{
  description = "Name of the organisation"
  type = string
  default = "expensely"
}

resource "aws_kms_key" "remote_state_key" {
  description = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation = true

  tags = local.tags

  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_kms_alias" "remote_state_key" {
  name = "alias/${lower(var.organisation_name)}/${lower(var.environment)}/${var.key_name}/backend"
  target_key_id = aws_kms_key.remote_state_key.key_id
}

resource "aws_iam_policy" "remote_state_key" {
  description = "Policy for terraform state bucket"
  name = "${var.iam_policy_prefix}-key"
  path = local.iam_path
  policy = data.aws_iam_policy_document.remote_state_key.json

  tags = local.tags
}
data "aws_iam_policy_document" "remote_state_key" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:ListKeys"
    ]
    resources = [
      aws_kms_key.remote_state_key.arn
    ]
  }
}

output "kms_key_iam_policy_arn" {
  value = aws_iam_policy.remote_state_key.arn
}
