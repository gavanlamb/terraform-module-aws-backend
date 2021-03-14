// USER
resource "aws_iam_user" "terraform" {
  name                 = var.username
  path                 = local.iam_path
  force_destroy        = true
  tags                 = merge(local.default_tags, var.user_tags)
}
resource "aws_iam_user_login_profile" "terraform" {
  user                    = aws_iam_user.terraform.name
  pgp_key                 = var.user_pgp_key
  password_reset_required = false
}
resource "aws_iam_access_key" "terraform" {
  user = aws_iam_user.terraform.name
}
resource "aws_iam_policy" "terraform" {
  description = "Policy for terraform state bucket"
  name = "terraform"
  path = local.iam_path
  policy = data.aws_iam_policy_document.terraform.json
}
data "aws_iam_policy_document" "terraform" {
  statement {
    effect = "Allow"
    actions = [
      "*"
    ]
    resources = [
      "*"
    ]
  }
}
resource "aws_iam_user_policy_attachment" "terraform"{
  user       = aws_iam_user.terraform.name
  policy_arn = aws_iam_policy.terraform.arn
}

// BUCKET
resource "aws_s3_bucket" "remote_state" {
  bucket = var.bucket_name
  acl = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(local.default_tags, var.bucket_tags)

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.remote_state_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
resource "aws_s3_account_public_access_block" "remote_state" {
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

// KMS
resource "aws_kms_key" "remote_state_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10

  lifecycle {
    prevent_destroy = true
  }
}

// DYNAMO
resource "aws_dynamodb_table" "lock_table" {
  name = var.dynamodb_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
  tags = merge(local.default_tags, var.dynamodb_tags)
}
