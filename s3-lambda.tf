################################################
### S3 bucket for Lambda's zip
################################################

module "s3_lambda" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket        = "${local.project_id_full}-lambda-zips"
  force_destroy = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    status     = "Enabled"
    mfa_delete = false
  }

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
}
