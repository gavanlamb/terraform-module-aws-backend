variable "bucket_name" {
  description = "The name of the bucket. If omitted, Terraform will assign a random, unique name. Must be less than or equal to 63 characters in length."
  type        = string
}

resource "aws_s3_bucket" "remote_state" {
  bucket = var.bucket_name
  
  lifecycle {
    prevent_destroy = true
  }

  tags = local.tags
}
resource "aws_s3_bucket_public_access_block" "remote_state" {
  bucket = aws_s3_bucket.remote_state.id
  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}
resource "aws_s3_bucket_logging" "remote_state" {
  bucket = aws_s3_bucket.remote_state.id
  target_bucket = aws_s3_bucket.remote_state.id
  target_prefix = "log/"
}
resource "aws_s3_bucket_acl" "remote_state" {
  bucket = aws_s3_bucket.remote_state.id
  acl    = "private"
}
resource "aws_s3_bucket_versioning" "remote_state" {
  bucket = aws_s3_bucket.remote_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "remote_state"{
  bucket = aws_s3_bucket.remote_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.remote_state_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "remote_state_ssl" {
  bucket = aws_s3_bucket.remote_state.id
  policy = data.aws_iam_policy_document.remote_state_ssl.json

  depends_on = [aws_s3_bucket_public_access_block.remote_state]
}
data "aws_iam_policy_document" "remote_state_ssl" {
  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      aws_s3_bucket.remote_state.arn,
      "${aws_s3_bucket.remote_state.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_iam_policy" "remote_state" {
  description = "Policy for terraform state bucket"
  name = "${var.iam_policy_prefix}-bucket"
  path = local.iam_path
  policy = data.aws_iam_policy_document.remote_state.json

  tags = local.tags
}
data "aws_iam_policy_document" "remote_state" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketVersioning"
    ]
    resources = [
      aws_s3_bucket.remote_state.arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListObject",
      "s3:PutObject"
    ]
    #tfsec:ignore:aws-iam-no-policy-wildcards
    resources = [
      "${aws_s3_bucket.remote_state.arn}/*"
    ]
  }
}

output "bucket_iam_policy_arn" {
  value = aws_iam_policy.remote_state.arn
}
