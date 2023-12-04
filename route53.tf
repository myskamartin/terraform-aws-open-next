data "aws_route53_zone" "main" {
  name         = var.project_domain
  private_zone = false
}
