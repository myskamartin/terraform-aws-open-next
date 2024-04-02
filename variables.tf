################################################
### Defaults
################################################

variable "aws_region" {
  type        = string
  description = "Default AWS region, used at the default AWS provider"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Terraform project name, used as prefix in all resources"
  default     = "open-next-demo"
}

variable "project_environment" {
  type        = string
  description = "Terraform project environment, used as prefix in all resources"
  default     = "dev"
}

variable "project_domain" {
  type        = string
  description = "Domain used for Application Load Balancer and certificate"
}

variable "build_dir" {
  type        = string
  description = "Directory where the build will be stored"
  default     = ".open-next"
}

################################################
### S3
################################################
###################################
### Origin
###################################

variable "assets_s3_origin_key" {
  type        = string
  description = "S3 key for asset files"
  default     = "_assets"
}

variable "cache_s3_origin_key" {
  type        = string
  description = "S3 key for cache files"
  default     = "_cache"
}

################################################
### Lambda
################################################
###################################
### Server function
###################################

variable "lambda_server_function_handler" {
  type        = string
  description = "Server function index handler"
  default     = "index.handler"
}

variable "lambda_server_function_runtime" {
  type        = string
  description = "Server function runtime"
  default     = "nodejs18.x"
}

variable "lambda_server_function_compatible_architectures" {
  type        = list(string)
  description = "Server function compatible architectures"
  default     = ["arm64"]
}

variable "lambda_server_function_memory_size" {
  type        = number
  description = "Server function memory size"
  default     = 1024
}

variable "lambda_server_function_storage_size" {
  type        = number
  description = "Server function storage size"
  default     = 512
}

variable "lambda_server_function_timeout" {
  type        = number
  description = "Server function timeout"
  default     = 10
}

###################################
### Image Optimization function
###################################

variable "lambda_image_optimization_function_handler" {
  type        = string
  description = "Server function index handler"
  default     = "index.handler"
}

variable "lambda_image_optimization_function_runtime" {
  type        = string
  description = "Server function runtime"
  default     = "nodejs18.x"
}

variable "lambda_image_optimization_function_compatible_architectures" {
  type        = list(string)
  description = "Server function compatible architectures"
  default     = ["arm64"]
}

variable "lambda_image_optimization_function_memory_size" {
  type        = number
  description = "Server function memory size"
  default     = 2048
}

variable "lambda_image_optimization_function_storage_size" {
  type        = number
  description = "Server function storage size"
  default     = 512
}

variable "lambda_image_optimization_function_timeout" {
  type        = number
  description = "Server function timeout"
  default     = 25
}

###################################
### ISR Revalidation function
###################################

variable "lambda_isr_revalidation_function_handler" {
  type        = string
  description = "Server function index handler"
  default     = "index.handler"
}

variable "lambda_isr_revalidation_function_runtime" {
  type        = string
  description = "Server function runtime"
  default     = "nodejs18.x"
}

variable "lambda_isr_revalidation_function_compatible_architectures" {
  type        = list(string)
  description = "Server function compatible architectures"
  default     = ["arm64"]
}

variable "lambda_isr_revalidation_function_memory_size" {
  type        = number
  description = "Server function memory size"
  default     = 512
}

variable "lambda_isr_revalidation_function_storage_size" {
  type        = number
  description = "Server function storage size"
  default     = 512
}

variable "lambda_isr_revalidation_function_timeout" {
  type        = number
  description = "Server function timeout"
  default     = 30
}

###################################
### Warmer function
###################################

variable "lambda_warmer_function_handler" {
  type        = string
  description = "Server function index handler"
  default     = "index.handler"
}

variable "lambda_warmer_function_runtime" {
  type        = string
  description = "Server function runtime"
  default     = "nodejs18.x"
}

variable "lambda_warmer_function_compatible_architectures" {
  type        = list(string)
  description = "Server function compatible architectures"
  default     = ["arm64"]
}

variable "lambda_warmer_function_memory_size" {
  type        = number
  description = "Server function memory size"
  default     = 256
}

variable "lambda_warmer_function_storage_size" {
  type        = number
  description = "Server function storage size"
  default     = 512
}

variable "lambda_warmer_function_timeout" {
  type        = number
  description = "Server function timeout"
  default     = 30
}

################################################
### CloudFront function
################################################

variable "cloudfront_function_runtime" {
  type        = string
  description = "CloudFront function runtime"
  default     = "cloudfront-js-1.0"
}

################################################
### CloudFront distribution
################################################

variable "cloudfront_distribution_is_ipv6_enabled" {
  type        = bool
  description = "CloudFront distribution is IPv6 enabled"
  default     = true
}

variable "cloudfront_distribution_http_version" {
  type        = string
  description = "CloudFront distribution HTTP version"
  default     = "http2and3"
}

variable "cloudfront_distribution_price_class" {
  type        = string
  description = "CloudFront distribution price class"
  default     = "PriceClass_100"
}

variable "cloudfront_distribution_web_acl_id" {
  type        = string
  description = "CloudFront distribution web ACL ID"
  default     = null
}
