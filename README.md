# Terraform Module AWS Backend
Provision AWS resources for Terraform backend

## Variables
| Variables     | Description                                                                                                                                                                                                                                                                               | Default     | Example                  |
|:--------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------|:-------------------------|
| environment   | Environment name. This value is used in tags.                                                                                                                                                                                                                                             |             | `production`             |
| name          | Name of infrastructure. This value is used in tags.                                                                                                                                                                                                                                       |             | `gavanlamb`              |
| iam_path      | Path name to store IAM policies and groups.                                                                                                                                                                                                                                               | `terraform` | `terraform`              |
| username      | The user's name. The name must consist of upper and lowercase alphanumeric characters with no spaces. You can also include any of the following characters: =,.@-_.. User names are not distinguished by case. For example, you cannot create users named both 'TESTUSER' and 'testuser'. | `terraform` | `creator`                |
| user_tags     | Tags to add to the user object. Merged with the default tags `Environment`, `Name` & `ManagedBy`                                                                                                                                                                                          |             |                          |
| bucket_name   | The name of the bucket. If omitted, Terraform will assign a random, unique name. Must be less than or equal to 63 characters in length.                                                                                                                                                   |             | `terraform-state-wwr234` |
| bucket_tags   | Tags to add to the bucket. Merged with the default tags `Environment`, `Name` & `ManagedBy`.                                                                                                                                                                                              |             |                          |
| dynamodb_name | The name of the table, this needs to be unique within a region.                                                                                                                                                                                                                           |             | `terraform-lock-wwr234`  |
| dynamodb_tags | Tags to add to the Dynamo table. Merged with the default tags `Environment`, `Name` & `ManagedBy`.                                                                                                                                                                                        |             |                          |

## How to
Specify the module source and the provider information.

### Sample
```hcl
provider "aws" {
    region = "ap-southeast-2"
}

module "backend" {
    environment    = "production"
    name           = "gavanlamb"
    iam_path	   = "terraform"
    username       = "terraform"
    user_tags      = {}
    bucket_name    = "terraform"
    bucket_tags    = {}
    dynamodb_name  = "terraform_lock"
    dynamodb_tags  = {}
}
```
