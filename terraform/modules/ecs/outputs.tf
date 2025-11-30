###############################################
# ECS Outputs
###############################################

output "cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.app.name
}

output "task_definition_arn" {
  description = "Task definition ARN for ECS"
  value       = aws_ecs_task_definition.app.arn
}
