provider "aws" {
  region = "us-east-1"
}

module "example" {
  source = "../"

  project_domain = "example.com"
}
