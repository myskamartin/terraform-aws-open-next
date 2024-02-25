# Terraform AWS OpenNext

> Work in progress. Currently, it does not offer many configuration options

> Works only in us-east-1 region

Terraform module to deploy Next.js app build with [open-next](https://open-next.js.org/) to AWS. The module uses existing public modules to simplify configuration and maintenance.

---

## Features

- [x] S3 origin
- [x] Upload asset files
- [x] Upload cache files
- [x] Hashed and unhashed files have proper `cache_control` set
- [x] DynamoDB with populated Revalidation table
- [x] Image optimization function
- [x] Server function
- [x] Revalidation function
- [x] CloudFront distribution
- [x] S3 Redirection from apex to www domain
- [ ] Use CloudFront default domain
- [ ] Fix Warmer function
- [ ] Running at the edge
- [ ] AWS WAF configuration with logging
- [ ] CloudFront distribution logging

## Usage

```hcl
module "open_next" {
  source = "myskamartin/open-next/aws"

  project_domain      = "example.com"
}
```

This module does not create a route53 hosted zone. Make sure that the hosted zone exists before deploying resources to AWS.

---

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.4 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cdn"></a> [cdn](#module\_cdn) | terraform-aws-modules/cloudfront/aws | 3.2.1 |
| <a name="module_cdn_redirect"></a> [cdn\_redirect](#module\_cdn\_redirect) | terraform-aws-modules/cloudfront/aws | 3.2.1 |
| <a name="module_image_optimization_function"></a> [image\_optimization\_function](#module\_image\_optimization\_function) | terraform-aws-modules/lambda/aws | 6.4.0 |
| <a name="module_isr_revalidation_dynamodb"></a> [isr\_revalidation\_dynamodb](#module\_isr\_revalidation\_dynamodb) | terraform-aws-modules/dynamodb-table/aws | 4.0.0 |
| <a name="module_isr_revalidation_function"></a> [isr\_revalidation\_function](#module\_isr\_revalidation\_function) | terraform-aws-modules/lambda/aws | 6.4.0 |
| <a name="module_isr_revalidation_sqs"></a> [isr\_revalidation\_sqs](#module\_isr\_revalidation\_sqs) | terraform-aws-modules/sqs/aws | 4.1.0 |
| <a name="module_s3_lambda"></a> [s3\_lambda](#module\_s3\_lambda) | terraform-aws-modules/s3-bucket/aws | 3.15.1 |
| <a name="module_s3_origin"></a> [s3\_origin](#module\_s3\_origin) | terraform-aws-modules/s3-bucket/aws | 3.15.1 |
| <a name="module_s3_redirect"></a> [s3\_redirect](#module\_s3\_redirect) | terraform-aws-modules/s3-bucket/aws | 3.15.1 |
| <a name="module_server_function"></a> [server\_function](#module\_server\_function) | terraform-aws-modules/lambda/aws | 6.4.0 |
| <a name="module_warmer_function"></a> [warmer\_function](#module\_warmer\_function) | terraform-aws-modules/lambda/aws | 6.4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_cache_policy.server_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_function.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_cloudwatch_event_rule.warmer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.warmer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_dynamodb_table_item.isr_revalidation_dynamodb_item](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table_item) | resource |
| [aws_lambda_event_source_mapping.isr_revalidation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_route53_record.a_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.a_alias_cdn_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.aaaa_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.aaaa_alias_cdn_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket_policy.s3_origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_object.cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.hashed_assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.unhashed_assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [null_resource.cdn_invalidate_cache](https://registry.terraform.io/providers/hashicorp/null/3.0/docs/resources/resource) | resource |
| [random_string.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_cloudfront_cache_policy.caching_optimized](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_cloudfront_origin_request_policy.all_viewer_except_host_header](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_origin_request_policy) | data source |
| [aws_iam_policy_document.s3_origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [local_file.dynamodb_cache](https://registry.terraform.io/providers/hashicorp/local/2.4/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assets_s3_origin_key"></a> [assets\_s3\_origin\_key](#input\_assets\_s3\_origin\_key) | S3 key for asset files | `string` | `"_assets"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Default AWS region, used at the default AWS provider | `string` | `"us-east-1"` | no |
| <a name="input_build_dir"></a> [build\_dir](#input\_build\_dir) | Directory where the build will be stored | `string` | `".open-next"` | no |
| <a name="input_cache_s3_origin_key"></a> [cache\_s3\_origin\_key](#input\_cache\_s3\_origin\_key) | S3 key for cache files | `string` | `"_cache"` | no |
| <a name="input_cloudfront_distribution_http_version"></a> [cloudfront\_distribution\_http\_version](#input\_cloudfront\_distribution\_http\_version) | CloudFront distribution HTTP version | `string` | `"http2and3"` | no |
| <a name="input_cloudfront_distribution_is_ipv6_enabled"></a> [cloudfront\_distribution\_is\_ipv6\_enabled](#input\_cloudfront\_distribution\_is\_ipv6\_enabled) | CloudFront distribution is IPv6 enabled | `bool` | `true` | no |
| <a name="input_cloudfront_distribution_price_class"></a> [cloudfront\_distribution\_price\_class](#input\_cloudfront\_distribution\_price\_class) | CloudFront distribution price class | `string` | `"PriceClass_100"` | no |
| <a name="input_cloudfront_function_runtime"></a> [cloudfront\_function\_runtime](#input\_cloudfront\_function\_runtime) | CloudFront function runtime | `string` | `"cloudfront-js-1.0"` | no |
| <a name="input_lambda_image_optimization_function_compatible_architectures"></a> [lambda\_image\_optimization\_function\_compatible\_architectures](#input\_lambda\_image\_optimization\_function\_compatible\_architectures) | Server function compatible architectures | `list(string)` | <pre>[<br>  "arm64"<br>]</pre> | no |
| <a name="input_lambda_image_optimization_function_handler"></a> [lambda\_image\_optimization\_function\_handler](#input\_lambda\_image\_optimization\_function\_handler) | Server function index handler | `string` | `"index.handler"` | no |
| <a name="input_lambda_image_optimization_function_memory_size"></a> [lambda\_image\_optimization\_function\_memory\_size](#input\_lambda\_image\_optimization\_function\_memory\_size) | Server function memory size | `number` | `2048` | no |
| <a name="input_lambda_image_optimization_function_runtime"></a> [lambda\_image\_optimization\_function\_runtime](#input\_lambda\_image\_optimization\_function\_runtime) | Server function runtime | `string` | `"nodejs18.x"` | no |
| <a name="input_lambda_image_optimization_function_storage_size"></a> [lambda\_image\_optimization\_function\_storage\_size](#input\_lambda\_image\_optimization\_function\_storage\_size) | Server function storage size | `number` | `512` | no |
| <a name="input_lambda_image_optimization_function_timeout"></a> [lambda\_image\_optimization\_function\_timeout](#input\_lambda\_image\_optimization\_function\_timeout) | Server function timeout | `number` | `25` | no |
| <a name="input_lambda_isr_revalidation_function_compatible_architectures"></a> [lambda\_isr\_revalidation\_function\_compatible\_architectures](#input\_lambda\_isr\_revalidation\_function\_compatible\_architectures) | Server function compatible architectures | `list(string)` | <pre>[<br>  "arm64"<br>]</pre> | no |
| <a name="input_lambda_isr_revalidation_function_handler"></a> [lambda\_isr\_revalidation\_function\_handler](#input\_lambda\_isr\_revalidation\_function\_handler) | Server function index handler | `string` | `"index.handler"` | no |
| <a name="input_lambda_isr_revalidation_function_memory_size"></a> [lambda\_isr\_revalidation\_function\_memory\_size](#input\_lambda\_isr\_revalidation\_function\_memory\_size) | Server function memory size | `number` | `512` | no |
| <a name="input_lambda_isr_revalidation_function_runtime"></a> [lambda\_isr\_revalidation\_function\_runtime](#input\_lambda\_isr\_revalidation\_function\_runtime) | Server function runtime | `string` | `"nodejs18.x"` | no |
| <a name="input_lambda_isr_revalidation_function_storage_size"></a> [lambda\_isr\_revalidation\_function\_storage\_size](#input\_lambda\_isr\_revalidation\_function\_storage\_size) | Server function storage size | `number` | `512` | no |
| <a name="input_lambda_isr_revalidation_function_timeout"></a> [lambda\_isr\_revalidation\_function\_timeout](#input\_lambda\_isr\_revalidation\_function\_timeout) | Server function timeout | `number` | `30` | no |
| <a name="input_lambda_server_function_compatible_architectures"></a> [lambda\_server\_function\_compatible\_architectures](#input\_lambda\_server\_function\_compatible\_architectures) | Server function compatible architectures | `list(string)` | <pre>[<br>  "arm64"<br>]</pre> | no |
| <a name="input_lambda_server_function_handler"></a> [lambda\_server\_function\_handler](#input\_lambda\_server\_function\_handler) | Server function index handler | `string` | `"index.handler"` | no |
| <a name="input_lambda_server_function_memory_size"></a> [lambda\_server\_function\_memory\_size](#input\_lambda\_server\_function\_memory\_size) | Server function memory size | `number` | `1024` | no |
| <a name="input_lambda_server_function_runtime"></a> [lambda\_server\_function\_runtime](#input\_lambda\_server\_function\_runtime) | Server function runtime | `string` | `"nodejs18.x"` | no |
| <a name="input_lambda_server_function_storage_size"></a> [lambda\_server\_function\_storage\_size](#input\_lambda\_server\_function\_storage\_size) | Server function storage size | `number` | `512` | no |
| <a name="input_lambda_server_function_timeout"></a> [lambda\_server\_function\_timeout](#input\_lambda\_server\_function\_timeout) | Server function timeout | `number` | `10` | no |
| <a name="input_lambda_warmer_function_compatible_architectures"></a> [lambda\_warmer\_function\_compatible\_architectures](#input\_lambda\_warmer\_function\_compatible\_architectures) | Server function compatible architectures | `list(string)` | <pre>[<br>  "arm64"<br>]</pre> | no |
| <a name="input_lambda_warmer_function_handler"></a> [lambda\_warmer\_function\_handler](#input\_lambda\_warmer\_function\_handler) | Server function index handler | `string` | `"index.handler"` | no |
| <a name="input_lambda_warmer_function_memory_size"></a> [lambda\_warmer\_function\_memory\_size](#input\_lambda\_warmer\_function\_memory\_size) | Server function memory size | `number` | `256` | no |
| <a name="input_lambda_warmer_function_runtime"></a> [lambda\_warmer\_function\_runtime](#input\_lambda\_warmer\_function\_runtime) | Server function runtime | `string` | `"nodejs18.x"` | no |
| <a name="input_lambda_warmer_function_storage_size"></a> [lambda\_warmer\_function\_storage\_size](#input\_lambda\_warmer\_function\_storage\_size) | Server function storage size | `number` | `512` | no |
| <a name="input_lambda_warmer_function_timeout"></a> [lambda\_warmer\_function\_timeout](#input\_lambda\_warmer\_function\_timeout) | Server function timeout | `number` | `30` | no |
| <a name="input_project_domain"></a> [project\_domain](#input\_project\_domain) | Domain used for Application Load Balancer and certificate | `string` | n/a | yes |
| <a name="input_project_environment"></a> [project\_environment](#input\_project\_environment) | Terraform project environment, used as prefix in all resources | `string` | `"dev"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Terraform project name, used as prefix in all resources | `string` | `"open-next-demo"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_region"></a> [aws\_region](#output\_aws\_region) | AWS region in which the infrastructure is deployed for the current environment |
| <a name="output_project_environment"></a> [project\_environment](#output\_project\_environment) | Project environment |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

[MIT](LICENSE) Licensed.
