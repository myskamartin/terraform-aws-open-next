terraform {
  required_version = "~> 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.0"
    }
  }
}
