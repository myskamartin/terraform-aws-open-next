################################################
### Server function
################################################

module "server_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.4.0"

  lambda_at_edge = false
  snap_start     = false

  function_name              = "${local.project_id_full}-server-fn"
  description                = "${var.project_name} Server function"
  handler                    = var.lambda_server_function_handler
  runtime                    = var.lambda_server_function_runtime
  compatible_architectures   = var.lambda_server_function_compatible_architectures
  memory_size                = var.lambda_server_function_memory_size
  ephemeral_storage_size     = var.lambda_server_function_storage_size
  timeout                    = var.lambda_server_function_timeout
  publish                    = true
  create_lambda_function_url = true
  create_package             = true

  source_path = [
    {
      path             = "${var.build_dir}/server-function/"
      npm_requirements = false
    }
  ]

  store_on_s3             = true
  s3_bucket               = module.s3_lambda.s3_bucket_id
  s3_prefix               = "server/"
  s3_object_storage_class = "STANDARD"

  artifacts_dir = local.artifacts_dir

  create_role              = true
  role_description         = "${var.project_name} execution role for Server Lambda function"
  attach_policy_statements = true
  policy_statements = {
    s3 = {
      effect = "Allow",
      actions = [
        "s3:DeleteObject*",
        "s3:PutObject",
        "s3:PutObjectVersionTagging",
        "s3:PutObjectLegalHold",
        "s3:PutObjectTagging",
        "s3:GetBucket*",
        "s3:List*",
        "s3:PutObjectRetention",
        "s3:Abort*",
        "s3:GetObject*"
      ]
      resources = [
        module.s3_origin.s3_bucket_arn,
        "${module.s3_origin.s3_bucket_arn}/*"
      ]
    },
    sqs = {
      effect = "Allow",
      actions = [
        "sqs:SendMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl"
      ]
      resources = [
        module.isr_revalidation_sqs.queue_arn
      ]
    },
    dynamodb = {
      effect = "Allow",
      actions = [
        "dynamodb:GetItem",
        "dynamodb:Query"
      ]
      resources = [
        "${module.isr_revalidation_dynamodb.dynamodb_table_arn}/*"
      ]
    },
  }

  attach_cloudwatch_logs_policy     = true
  cloudwatch_logs_retention_in_days = 14

  environment_variables = {
    CACHE_BUCKET_KEY_PREFIX     = var.cache_s3_origin_key
    CACHE_BUCKET_NAME           = module.s3_origin.s3_bucket_id
    CACHE_BUCKET_REGION         = var.aws_region
    REINVALIDATION_QUEUE_REGION = var.aws_region
    REINVALIDATION_QUEUE_URL    = module.isr_revalidation_sqs.queue_url
    CACHE_DYNAMO_TABLE          = module.isr_revalidation_dynamodb.dynamodb_table_id
  }
}
