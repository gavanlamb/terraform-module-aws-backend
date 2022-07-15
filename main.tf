// USER
resource "aws_iam_user" "terraform" {
  name = var.username
  path = local.iam_path
  force_destroy = true
  tags = merge(local.default_tags, var.tags)
}
resource "aws_iam_access_key" "terraform" {
  user = aws_iam_user.terraform.name
}
resource "aws_iam_policy" "terraform" {
  description = "Policy for terraform state bucket"
  name = var.policy_name
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
resource "aws_iam_user_policy_attachment" "terraform" {
  user = aws_iam_user.terraform.name
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

  tags = merge(local.default_tags, var.tags)

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.remote_state_key.arn
        sse_algorithm = "aws:kms"
      }
    }
  }
}
resource "aws_s3_bucket_public_access_block" "remote_state" {
  bucket = aws_s3_bucket.remote_state.id
  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}

// KMS
resource "aws_kms_key" "remote_state_key" {
  description = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation = true
  policy = data.aws_iam_policy_document.terraform.json
  tags = merge(local.default_tags, var.tags)

  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_kms_alias" "remote_state_key" {
  name = "alias/expensely/${lower(var.environment)}/${var.key_name}"
  target_key_id = aws_kms_key.remote_state_key.key_id
}
data "aws_iam_policy_document" "remote_state_key" {
  statement {
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = [
        "monitoring.${data.aws_region.current.name}.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = [
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
      ]
    }
  }
}


// DYNAMO
resource "aws_dynamodb_table" "lock_table" {
  name = var.dynamodb_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption { 
    enabled = true
    kms_key_arn = aws_kms_alias.remote_state_key.arn
  }
  
  lifecycle {
    prevent_destroy = true
  }
  tags = merge(local.default_tags, var.tags)
}
