output "aws_region" {
  description = "AWS region in which the infrastructure is deployed for the current environment"
  value       = var.aws_region
  sensitive   = false
}

output "project_environment" {
  description = "Project environment"
  value       = var.project_environment
  sensitive   = false
}
