################################################
### Revalidation function
################################################

module "isr_revalidation_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.4.0"

  lambda_at_edge = false
  snap_start     = false

  function_name              = "${local.project_id_full}-isr-revalidation-fn"
  description                = "${var.project_name} ISR Revalidation function"
  handler                    = var.lambda_isr_revalidation_function_handler
  runtime                    = var.lambda_isr_revalidation_function_runtime
  compatible_architectures   = var.lambda_isr_revalidation_function_compatible_architectures
  memory_size                = var.lambda_isr_revalidation_function_memory_size
  ephemeral_storage_size     = var.lambda_isr_revalidation_function_storage_size
  timeout                    = var.lambda_isr_revalidation_function_timeout
  publish                    = true
  create_lambda_function_url = true
  create_package             = true

  source_path = [
    {
      path             = "${var.build_dir}/revalidation-function/"
      npm_requirements = false
    }
  ]

  store_on_s3             = true
  s3_bucket               = module.s3_lambda.s3_bucket_id
  s3_prefix               = "revalidation/"
  s3_object_storage_class = "STANDARD"

  artifacts_dir = local.artifacts_dir

  create_role              = true
  role_description         = "${var.project_name} execution role for ISR Revalidation Lambda function"
  attach_policy_statements = true
  policy_statements = {
    sqs = {
      effect = "Allow",
      actions = [
        "sqs:ReceiveMessage",
        "sqs:ChangeMessageVisibility",
        "sqs:GetQueueUrl",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]
      resources = [
        module.isr_revalidation_sqs.queue_arn
      ]
    }
  }

  attach_cloudwatch_logs_policy     = true
  cloudwatch_logs_retention_in_days = 14
}

################################################
### SQS
################################################

module "isr_revalidation_sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.1.0"

  name                        = "${local.project_id_full}-isr-revalidation"
  fifo_queue                  = true
  content_based_deduplication = true
  dlq_sqs_managed_sse_enabled = true
  create_dlq                  = true

  redrive_policy = {
    maxReceiveCount = 10
  }
}

resource "aws_lambda_event_source_mapping" "isr_revalidation" {
  event_source_arn = module.isr_revalidation_sqs.queue_arn
  function_name    = module.isr_revalidation_function.lambda_function_arn
}
