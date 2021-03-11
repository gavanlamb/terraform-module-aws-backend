variable "company" {
  type = string
  description = "Company name"
}
variable "environment" {
  type = string
  description = "Environment name"
}
variable "name" {
  type = string
  description = "Name"
}
variable "service" {
  type = string
  description = "Service name"
}
variable "group_name" {
  type = string
  description = "The group for all the terraform policies"
}
variable "iam_path" {
  type = string
  description = "The path to store policies and groups"
}
variable "bucket_name" {
  type = string
  description = "Name of the bucket"
}
variable "bucket_tags" {
  description = "Tags for the s3 bucket"
  type = "map"
  default = {}
}
variable "dynamodb_name" {
  type = string
  description = "Name of the dynamodb table"
}
variable "dynamodb_tags" {
  description = "Tags for the dynamodb table"
  type = "map"
  default = {}
}

locals {
  default_tags = {
    Company = var.company
    Environment = var.environment
    Name = var.name
    service = var.service
    ManagedBy = "Terraform"
  }
}
