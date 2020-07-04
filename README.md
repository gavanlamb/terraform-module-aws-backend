# Terraform AWS Backend
Creates the AWS resources for the terraform backend

## Variables
### Input
| Variables     | Description                                                    |
|:--------------|:---------------------------------------------------------------|
| company       | Company name                                                   |
| environment   | Environment name                                               |
| name          | Name                                                           |
| service       | Service name                                                   |
| group_name    | The group name for all the terraform policies backend policies |
| iam_path      | The path to store IAM policies and groups                      |
| bucket_name   | Name of the bucket                                             |
| bucket_tags   | Tags                                                           |
| dynamodb_name | Name of the dynamodb                                           |
| dynamodb_tags | Tags                                                           |

## How to 
Specify the module source and the provider information.

### Sample
```
provider "aws" {
    region = "${var.region}"
    shared_credentials_file = "${var.credentials_file}"
}

module "backend" {
    source = "github.com/Haplo-tech/Terraform.Module.AWS.Backend"
    company = ""
    environment = ""
    name = ""
    service = ""
    group_name 	= "terraform"
    iam_path	= "terraform"
    bucket_name = ""
    bucket_tags = {}
    dynamodb_name = ""
    dynamodb_tags = {}
}
```
