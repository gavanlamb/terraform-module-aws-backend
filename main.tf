locals {
  default_tags = {
    Company = var.company
    Environment = var.environment
    Name = var.name
    service = var.service
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_group" "terraform_remote_state" {
  name = var.group_name
  path = "/${var.iam_path}/"
}

resource "aws_s3_bucket" "terraform_remote_state" {
  bucket = var.bucket_name
  acl = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(local.default_tags, var.bucket_tags)
}
resource "aws_iam_policy" "terraform_remote_state" {
  name = aws_s3_bucket.terraform_remote_state.id
  path = "/${var.iam_path}/"
  description = "Policy for terraform state bucket"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "${aws_s3_bucket.terraform_remote_state.arn}"
    }
  ]
}
EOF
}
resource "aws_iam_group_policy_attachment" "test-terraform_remote_state" {
  group = aws_iam_group.terraform_remote_state.name
  policy_arn = aws_iam_policy.terraform_remote_state.arn
}

resource "aws_dynamodb_table" "terraform_remote_state_lock" {
  name = var.dynamodb_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(local.default_tags, var.dynamodb_tags)
}
resource "aws_iam_policy" "terraform_remote_state_lock" {
  name = var.dynamodb_name
  path = "/${var.iam_path}/"
  description = "Policy for terraform dynamodb state lock table"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "${aws_dynamodb_table.terraform_remote_state_lock.arn}"
    }
  ]
}
EOF
}
resource "aws_iam_group_policy_attachment" "test-terraform_remote_state_lock" {
  group = aws_iam_group.terraform_remote_state.name
  policy_arn = aws_iam_policy.terraform_remote_state_lock.arn
}
