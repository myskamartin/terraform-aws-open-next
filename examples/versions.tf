terraform {
  required_version = ">= 1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.21.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    # In case you want to use S3 as a backend.
    # This is optional.
    # Resources need to be created prior before moving forward with deployment.
    # For example configuration please check https://github.com/cloudposse/terraform-aws-tfstate-backend and follow the insttruction.
    #    backend "s3" {
    #      bucket         = ""
    #      key            = ""
    #      region         = ""
    #      profile        = ""
    #      dynamodb_table = ""
    #      encrypt        = true/false
    #    }
  }
}
