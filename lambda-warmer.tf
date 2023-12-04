################################################
### Warmer function
################################################

module "warmer_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.4.0"

  lambda_at_edge = false
  snap_start     = false

  function_name              = "${local.project_id_full}-warmer-function"
  description                = "${var.project_name} Warmer function"
  handler                    = var.lambda_warmer_function_handler
  runtime                    = var.lambda_warmer_function_runtime
  compatible_architectures   = var.lambda_warmer_function_compatible_architectures
  memory_size                = var.lambda_warmer_function_memory_size
  ephemeral_storage_size     = var.lambda_warmer_function_storage_size
  timeout                    = var.lambda_warmer_function_timeout
  publish                    = true
  create_lambda_function_url = true
  create_package             = true

  source_path = [
    {
      path             = "${var.build_dir}/warmer-function/"
      npm_requirements = false
    }
  ]

  store_on_s3             = true
  s3_bucket               = module.s3_lambda.s3_bucket_id
  s3_prefix               = "warmer/"
  s3_object_storage_class = "STANDARD"

  artifacts_dir = local.artifacts_dir

  create_role              = true
  role_description         = "${var.project_name} execution role for Warmer Lambda function"
  attach_policy_statements = true
  policy_statements = {
    lambda = {
      effect = "Allow",
      actions = [
        "lambda:InvokeFunction"
      ]
      resources = [
        module.server_function.lambda_function_arn
      ]
    }
  }

  attach_cloudwatch_logs_policy     = true
  cloudwatch_logs_retention_in_days = 14

  environment_variables = {
    FUNCTION_NAME     = module.server_function.lambda_function_name
    CONCURRENCY_LIMIT = 2
  }

  allowed_triggers = {
    warmer-rule = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.warmer.arn
    }
  }
}

################################################
###### EventBridge
################################################

resource "aws_cloudwatch_event_rule" "warmer" {
  name                = "${local.project_id_full}-warmer"
  description         = ""
  schedule_expression = "rate(5 minutes)"
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "warmer" {
  rule = aws_cloudwatch_event_rule.warmer.name
  arn  = module.warmer_function.lambda_function_arn
}
