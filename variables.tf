variable "environment" {
  description = "Environment name. This value is used as a tag."
  type        = string
}
variable "name" {
  description = "Name of infrastructure. This value is used in tags."
  type        = string
}

variable "iam_path" {
  description = "Path name to store IAM policies and groups."
  type        = string
  default     = "terraform"
}
variable "username" {
  description = "The user's name. The name must consist of upper and lowercase alphanumeric characters with no spaces. You can also include any of the following characters: =,.@-_.. User names are not distinguished by case. For example, you cannot create users named both 'TESTUSER' and 'testuser'."
  type        = string
  default     = "terraform"
}

variable "policy_name" {
  description = "The name of the policy. The name must consist of upper and lowercase alphanumeric characters with no spaces. You can also include any of the following characters: =,.@-_.. User names are not distinguished by case. For example, you cannot create users named both 'TESTUSER' and 'testuser'."
  type        = string
  default     = "terraform"
}

variable "bucket_name" {
  description = "The name of the bucket. If omitted, Terraform will assign a random, unique name. Must be less than or equal to 63 characters in length."
  type        = string
}

variable "dynamodb_name" {
  description = "The name of the table, this needs to be unique within a region."
  type        = string
}

variable "key_name"{
  description = "The name the KMS key."
  type = string
  default = "terraform-key"
}
variable "tags" {
  description = "Tags to add to resources. Merged with the default tags `Environment`, `Name` & `ManagedBy`."
  type        = map(string)
  default     = {}
}

locals {
  default_tags = {
    Environment = var.environment
    Name = var.name
    ManagedBy = "Terraform"
  }
  iam_path = "/${var.iam_path}/"
}
