# terraform/outputs.tf
output "vpc_id" {
  value = aws_vpc.main.id
}

# output "alb_dns_name" {
#   description = "Public DNS name of the ALB – use this to hit the apps"
#   value       = aws_lb.frontend_alb.dns_name
# }

output "backend_ecr_repo_url" {
  description = "Full ECR repo URL for the Flask image"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_ecr_repo_url" {
  description = "Full ECR repo URL for the Express image"
  value       = aws_ecr_repository.frontend.repository_url
}