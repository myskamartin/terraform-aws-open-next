provider "aws" {
  region                      = "us-east-1"
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = false

  default_tags {
    tags = {
      Project     = "open-next-demo"
      App         = "open-next-demo"
      ManagedBy   = "Terraform"
      Environment = "dev"
    }
  }
}

module "example" {
  source = "../"

  project_domain = "example.com"
}
