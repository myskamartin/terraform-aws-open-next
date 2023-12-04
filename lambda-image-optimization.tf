################################################
### Image Optimization function
################################################

module "image_optimization_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.4.0"

  lambda_at_edge = false
  snap_start     = false

  function_name              = "${local.project_id_full}-image-optimize-fn"
  description                = "${var.project_name} Image Optimization function"
  handler                    = var.lambda_image_optimization_function_handler
  runtime                    = var.lambda_image_optimization_function_runtime
  compatible_architectures   = var.lambda_image_optimization_function_compatible_architectures
  memory_size                = var.lambda_image_optimization_function_memory_size
  ephemeral_storage_size     = var.lambda_image_optimization_function_storage_size
  timeout                    = var.lambda_image_optimization_function_timeout
  publish                    = true
  create_lambda_function_url = true
  create_package             = true

  source_path = [
    {
      path             = "${var.build_dir}/image-optimization-function/"
      npm_requirements = false
    }
  ]

  store_on_s3             = true
  s3_bucket               = module.s3_lambda.s3_bucket_id
  s3_prefix               = "image-optimization/"
  s3_object_storage_class = "STANDARD"

  artifacts_dir = local.artifacts_dir

  create_role              = true
  role_description         = "${var.project_name} execution role for Image Optimization Lambda function"
  attach_policy_statements = true
  policy_statements = {
    s3 = {
      effect = "Allow",
      actions = [
        "s3:GetObject*"
      ]
      resources = [
        "${module.s3_origin.s3_bucket_arn}/*"
      ]
    }
  }

  attach_cloudwatch_logs_policy     = true
  cloudwatch_logs_retention_in_days = 14

  environment_variables = {
    BUCKET_NAME       = module.s3_origin.s3_bucket_id
    BUCKET_KEY_PREFIX = var.assets_s3_origin_key
  }
}
