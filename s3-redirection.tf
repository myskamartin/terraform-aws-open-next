################################################
### S3 redirection from apex to www
################################################

module "s3_redirect" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket        = "${local.project_id_full}-redirection"
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

  website = {
    redirect_all_requests_to = {
      host_name = "www.${var.project_domain}"
      protocol  = "https"
    }
  }
}

################################################
### CloudFront distribution
################################################

module "cdn_redirect" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.2.1"

  aliases             = [var.project_domain]
  comment             = "Redirection from ${var.project_domain} to www.${var.project_domain}"
  enabled             = true
  is_ipv6_enabled     = var.cloudfront_distribution_is_ipv6_enabled
  http_version        = var.cloudfront_distribution_http_version
  price_class         = var.cloudfront_distribution_price_class
  retain_on_delete    = false
  wait_for_deployment = true

  viewer_certificate = {
    acm_certificate_arn            = aws_acm_certificate.main.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  origin = {
    s3 = {
      domain_name         = module.s3_redirect.s3_bucket_website_endpoint
      origin_id           = module.s3_redirect.s3_bucket_id
      connection_attempts = 3
      connection_timeout  = 10
      custom_origin_config = {
        http_port                = 80
        https_port               = 443
        origin_protocol_policy   = "http-only"
        origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
        origin_keepalive_timeout = 5
        origin_read_timeout      = 30
      }
    }
  }

  default_cache_behavior = {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = module.s3_redirect.s3_bucket_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    use_forwarded_values   = true
    query_string           = false
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

resource "aws_route53_record" "a_alias_cdn_redirect" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.project_domain
  type    = "A"

  alias {
    name                   = module.cdn_redirect.cloudfront_distribution_domain_name
    zone_id                = module.cdn_redirect.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = true
  }
}

######################
### AAAA record
######################

resource "aws_route53_record" "aaaa_alias_cdn_redirect" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.project_domain
  type    = "AAAA"

  alias {
    name                   = module.cdn_redirect.cloudfront_distribution_domain_name
    zone_id                = module.cdn_redirect.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = true
  }
}
