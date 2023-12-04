################################################
### S3 origin
################################################

module "s3_origin" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket        = "${local.project_id_full}-origin"
  force_destroy = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    status     = "Suspended"
    mfa_delete = false
  }

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
}

data "aws_iam_policy_document" "s3_origin" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_origin.s3_bucket_arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        module.cdn.cloudfront_distribution_arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_origin" {
  bucket = module.s3_origin.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_origin.json
}

################################################
### Upload files to origin
################################################
#################################
### Un-hashed asset files
#################################

resource "aws_s3_object" "unhashed_assets" {
  for_each      = local.unhashed_assets
  bucket        = module.s3_origin.s3_bucket_id
  key           = "${var.assets_s3_origin_key}/${each.value.path}"
  source        = "${var.build_dir}/assets/${each.value.path}"
  source_hash   = filemd5("${var.build_dir}/assets/${each.value.path}")
  cache_control = "public,max-age=0,s-maxage=31536000,must-revalidate"
  content_type  = lookup(local.content_types, each.value.content_type, "text/plain")
}

#################################
### Hashed asset files
###############################

resource "aws_s3_object" "hashed_assets" {
  for_each      = local.hashed_assets
  bucket        = module.s3_origin.s3_bucket_id
  key           = "${var.assets_s3_origin_key}/${each.value.path}"
  source        = "${var.build_dir}/assets/${each.value.path}"
  source_hash   = filemd5("${var.build_dir}/assets/${each.value.path}")
  cache_control = "public,max-age=31536000,immutable"
  content_type  = lookup(local.content_types, each.value.content_type, "text/plain")
}

#################################
###### Cache files
#################################

resource "aws_s3_object" "cache" {
  for_each     = local.cache_files
  bucket       = module.s3_origin.s3_bucket_id
  key          = "${var.cache_s3_origin_key}/${each.value.path}"
  source       = "${var.build_dir}/cache/${each.value.path}"
  source_hash  = filemd5("${var.build_dir}/cache/${each.value.path}")
  content_type = lookup(local.content_types, each.value.content_type, "text/plain")
}
