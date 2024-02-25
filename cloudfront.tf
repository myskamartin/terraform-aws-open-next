################################################
### CloudFront function
################################################

resource "aws_cloudfront_function" "main" {
  name    = "${local.project_id_full}-preserve-host"
  runtime = var.cloudfront_function_runtime
  comment = "${var.project_name} Next.js Function for Preserving Original Host"
  publish = true
  code    = <<EOF
function handler(event) {
  var request = event.request;
  request.headers["x-forwarded-host"] = request.headers.host;
  return request;
}
EOF
}

################################################
### Cache policies
################################################

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "all_viewer_except_host_header" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudfront_cache_policy" "server_cache" {
  name        = "${local.project_id_full}-server-cache"
  comment     = "${var.project_name} Server cache policy"
  default_ttl = 0
  max_ttl     = 31536000
  min_ttl     = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
    cookies_config {
      cookie_behavior = "all"
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["next-url", "rsc", "next-router-prefetch", "next-router-state-tree", "accept"]
      }
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

################################################
### CloudFront distribution
################################################

module "cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.2.1"

  aliases             = ["www.${var.project_domain}"]
  comment             = "www.${var.project_domain}"
  enabled             = true
  is_ipv6_enabled     = var.cloudfront_distribution_is_ipv6_enabled
  http_version        = var.cloudfront_distribution_http_version
  price_class         = var.cloudfront_distribution_price_class
  retain_on_delete    = false
  wait_for_deployment = true

  create_origin_access_identity = false
  create_origin_access_control  = true
  origin_access_control = {
    "${local.project_id}-s3-oac" = {
      description      = "Managed by Terraform"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  viewer_certificate = {
    acm_certificate_arn            = aws_acm_certificate.main.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  origin = {
    s3 = {
      domain_name           = module.s3_origin.s3_bucket_bucket_regional_domain_name
      origin_id             = module.s3_origin.s3_bucket_id
      origin_path           = "/${var.assets_s3_origin_key}"
      origin_access_control = "${local.project_id}-s3-oac"
      connection_attempts   = 3
      connection_timeout    = 10
    }
    server_lambda = {
      domain_name         = "${module.server_function.lambda_function_url_id}.lambda-url.${var.aws_region}.on.aws"
      origin_id           = module.server_function.lambda_function_name
      connection_attempts = 3
      connection_timeout  = 10
      custom_origin_config = {
        http_port                = 80
        https_port               = 443
        origin_protocol_policy   = "https-only"
        origin_ssl_protocols     = ["TLSv1.2"]
        origin_keepalive_timeout = 5
        origin_read_timeout      = 30
      }
    }
    image_optimization_lambda = {
      domain_name         = "${module.image_optimization_function.lambda_function_url_id}.lambda-url.${var.aws_region}.on.aws"
      origin_id           = module.image_optimization_function.lambda_function_name
      connection_attempts = 3
      connection_timeout  = 10
      custom_origin_config = {
        http_port                = 80
        https_port               = 443
        origin_protocol_policy   = "https-only"
        origin_ssl_protocols     = ["TLSv1.2"]
        origin_keepalive_timeout = 5
        origin_read_timeout      = 30
      }
    }
  }

  ordered_cache_behavior = [
    {
      path_pattern             = "api/*"
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods           = ["GET", "HEAD", "OPTIONS"]
      target_origin_id         = module.server_function.lambda_function_name
      viewer_protocol_policy   = "redirect-to-https"
      cache_policy_id          = aws_cloudfront_cache_policy.server_cache.id
      origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host_header.id
      compress                 = true
      use_forwarded_values     = false
      query_string             = false

      function_association = {
        viewer-request = {
          function_arn = aws_cloudfront_function.main.arn
        }
      }
    },
    {
      path_pattern             = "_next/data/*"
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods           = ["GET", "HEAD", "OPTIONS"]
      target_origin_id         = module.server_function.lambda_function_name
      viewer_protocol_policy   = "redirect-to-https"
      cache_policy_id          = aws_cloudfront_cache_policy.server_cache.id
      origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host_header.id
      compress                 = true
      use_forwarded_values     = false
      query_string             = false

      function_association = {
        viewer-request = {
          function_arn = aws_cloudfront_function.main.arn
        }
      }
    },
    {
      path_pattern             = "_next/image*"
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods           = ["GET", "HEAD", "OPTIONS"]
      target_origin_id         = module.image_optimization_function.lambda_function_name
      viewer_protocol_policy   = "redirect-to-https"
      cache_policy_id          = aws_cloudfront_cache_policy.server_cache.id
      origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host_header.id
      compress                 = true
      use_forwarded_values     = false
      query_string             = false

      function_association = {
        viewer-request = {
          function_arn = aws_cloudfront_function.main.arn
        }
      }
    },
    {
      path_pattern           = "BUILD_ID"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      target_origin_id       = module.s3_origin.s3_bucket_id
      viewer_protocol_policy = "redirect-to-https"
      cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
      compress               = true
      use_forwarded_values   = false
      query_string           = false
    },
    {
      path_pattern           = "_next/*"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD", "OPTIONS"]
      target_origin_id       = module.s3_origin.s3_bucket_id
      viewer_protocol_policy = "redirect-to-https"
      cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
      compress               = true
      use_forwarded_values   = false
      query_string           = false
    },
    {
      path_pattern           = "fonts/*"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD", "OPTIONS"]
      target_origin_id       = module.s3_origin.s3_bucket_id
      viewer_protocol_policy = "redirect-to-https"
      cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
      compress               = true
      use_forwarded_values   = false
      query_string           = false
    },
    {
      path_pattern           = "images/*"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD", "OPTIONS"]
      target_origin_id       = module.s3_origin.s3_bucket_id
      viewer_protocol_policy = "redirect-to-https"
      cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
      compress               = true
      use_forwarded_values   = false
      query_string           = false
    }
  ]

  default_cache_behavior = {
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    target_origin_id         = module.server_function.lambda_function_name
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = aws_cloudfront_cache_policy.server_cache.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host_header.id
    compress                 = true
    use_forwarded_values     = false
    query_string             = false

    function_association = {
      viewer-request = {
        function_arn = aws_cloudfront_function.main.arn
      }
    }
  }

  geo_restriction = {
    restriction_type = "none"
  }
}

#############################
### Route53 record
#############################
######################
### A record
######################

resource "aws_route53_record" "a_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${var.project_domain}"
  type    = "A"

  alias {
    name                   = module.cdn.cloudfront_distribution_domain_name
    zone_id                = module.cdn.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = true
  }
}

######################
### AAAA record
######################

resource "aws_route53_record" "aaaa_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${var.project_domain}"
  type    = "AAAA"

  alias {
    name                   = module.cdn.cloudfront_distribution_domain_name
    zone_id                = module.cdn.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = true
  }
}

#############################
### Cache invalidation
#############################

resource "null_resource" "cdn_invalidate_cache" {
  triggers = {
    distribution_id   = module.cdn.cloudfront_distribution_id
    distribution_etag = module.cdn.cloudfront_distribution_etag
    combined_source_hash = join("", flatten([
      values(aws_s3_object.unhashed_assets)[*].source_hash,
      values(aws_s3_object.hashed_assets)[*].source_hash,
      values(aws_s3_object.cache)[*].source_hash
  ])) }

  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${self.triggers.distribution_id} --paths '/*' --query 'Invalidation.Id' | xargs -I{} aws cloudfront wait invalidation-completed --distribution-id ${self.triggers.distribution_id} --id {}"
  }
}
