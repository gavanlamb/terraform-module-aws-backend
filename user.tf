variable "username" {
  description = "The user's name. The name must consist of upper and lowercase alphanumeric characters with no spaces. You can also include any of the following characters: =,.@-_.. User names are not distinguished by case. For example, you cannot create users named both 'TESTUSER' and 'testuser'."
  type        = string
  default     = "terraform"
}

resource "aws_iam_user" "terraform" {
  name = var.username
  path = local.iam_path
  force_destroy = true
  tags = local.tags

  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_iam_access_key" "terraform" {
  user = aws_iam_user.terraform.name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_user_policy_attachment" "remote_state" {
  user = aws_iam_user.terraform.name
  policy_arn = aws_iam_policy.remote_state.arn
}
resource "aws_iam_user_policy_attachment" "remote_lock" {
  user = aws_iam_user.terraform.name
  policy_arn = aws_iam_policy.remote_lock.arn
}
resource "aws_iam_user_policy_attachment" "remote_state_key" {
  user = aws_iam_user.terraform.name
  policy_arn = aws_iam_policy.remote_state_key.arn
}

output "aws_iam_user_arn" {
  value = aws_iam_user.terraform.arn
}
output "aws_iam_user_access_key" {
  value = aws_iam_access_key.terraform.id
}
output "aws_iam_user_secret_key" {
  sensitive = true
  value = aws_iam_access_key.terraform.secret
}

