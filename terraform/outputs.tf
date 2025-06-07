# terraform/outputs.tf
output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "Application Load Balancer DNS name"
}

output "ecr_repository_url" {
  value       = data.aws_ecr_repository.app.repository_url
  description = "ECR Repository URL"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.my_cluster.name
  description = "ECS Cluster name"
}

output "secrets_manager_arn" {
  value       = aws_secretsmanager_secret.app_secrets.arn
  description = "ARN of the Secrets Manager secret"
}

output "db_password" {
  value       = random_password.db_password.result
  sensitive   = true
  description = "Generated database password"
}

output "efs_id" {
  value = aws_efs_file_system.persistent_data.id
}

output "efs_dns_name" {
  value = aws_efs_file_system.persistent_data.dns_name
}

output "postgres_access_point_id" {
  value = aws_efs_access_point.postgres.id
}

output "elasticsearch_access_point_id" {
  value = aws_efs_access_point.elasticsearch.id
}