################################################
### DynamoDB for ISR Revalidation
################################################

module "isr_revalidation_dynamodb" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.0.0"

  name                        = "${local.project_id_full}-isr-revalidation"
  create_table                = true
  deletion_protection_enabled = false
  billing_mode                = "PROVISIONED"
  read_capacity               = 5
  write_capacity              = 5
  table_class                 = "STANDARD"
  hash_key                    = "tag"
  range_key                   = "path"

  attributes = [
    {
      name = "tag"
      type = "S"
    },
    {
      name = "path"
      type = "S"
    },
    {
      name = "revalidatedAt"
      type = "N"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "revalidate"
      hash_key        = "path"
      range_key       = "revalidatedAt"
      projection_type = "ALL"
      write_capacity  = 5
      read_capacity   = 5
    }
  ]
}

###################################
### Upload items to DynamoDB
###################################

resource "aws_dynamodb_table_item" "isr_revalidation_dynamodb_item" {
  for_each = { for idx, item in local.transformed_data : idx => item }

  table_name = module.isr_revalidation_dynamodb.dynamodb_table_id
  hash_key   = "tag"
  range_key  = "path"

  item = jsonencode(each.value)
}
