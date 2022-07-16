variable "iam_path" {
  description = "Path name to store IAM policies and groups."
  type        = string
  default     = "terraform"
}
variable "iam_policy_prefix" {
  description = "The name of the policy. The name must consist of upper and lowercase alphanumeric characters with no spaces. You can also include any of the following characters: =,.@-_.. User names are not distinguished by case. For example, you cannot create users named both 'TESTUSER' and 'testuser'."
  type        = string
  default     = "terraform"
}

variable "environment" {
  description = "Environment name. This value is used as a tag."
  type        = string
}
variable "name" {
  description = "Name of infrastructure. This value is used in tags."
  type        = string
}
variable "tags" {
  description = "Tags to add to resources. Merged with the default tags `Environment`, `Name` & `ManagedBy`."
  type        = map(string)
  default     = {}
}

locals {
  tags =  merge(
    {
      Environment = var.environment
      Name = var.name
      ManagedBy = "Terraform"
    },
    var.tags
  )
  
  iam_path = "/${var.iam_path}/"
}
