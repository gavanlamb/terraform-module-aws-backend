# Terraform Module AWS Backend
Provision AWS resources for Terraform backend

## Variables
| Variables         | Description                                                                                                                                                                                                                                                                               | Default         | Example                  |
|:------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------|:-------------------------|
| environment       | Environment name. This value is used as a tag key-value.                                                                                                                                                                                                                                  |                 | `production`             |
| name              | Name of infrastructure. This value is used as a tag key-value.                                                                                                                                                                                                                            |                 | `gavanlamb`              |
| tags              | Tags to add to all resources. Merged with the default tags `Environment`, `Name` & `ManagedBy`                                                                                                                                                                                            |                 |                          |
| iam_path          | Path name to store IAM policies under                                                                                                                                                                                                                                                     | `terraform`     | `terraform`              |
| iam_policy_prefix | IAM policy name prefix                                                                                                                                                                                                                                                                    |                 |                          |
| bucket_name       | Name of the bucket. If omitted, Terraform will assign a random, unique name. Must be less than or equal to 63 characters in length.                                                                                                                                                       |                 |                          |
| dynamodb_name     | Name of the table, this needs to be unique within the specified region.                                                                                                                                                                                                                   |                 |                          |
| key_name          | Name of the key, this needs to be unique.                                                                                                                                                                                                                                                 | `terraform-key` |                          |

## How to
Specify the module source and the provider information.

### Sample
```hcl
provider "aws" {
    region = "ap-southeast-2"
}

module "backend" {
    source = "github.com/expensely/terraform-module-aws-backend"
    environment = "production"
    name = "gavanlamb"
    iam_path = "terraform"
    iam_policy_prefix = "terraform"
    bucket_name = "terraform"
    dynamodb_name = "terraform_lock"
    key_name = "terraform"
    tags = {}
}
```
