output "application_name" {
  description = "CodeDeploy ECS application name"
  value       = aws_codedeploy_app.ecs.name
}

output "deployment_group_name" {
  description = "CodeDeploy ECS deployment group name"
  value       = aws_codedeploy_deployment_group.ecs.deployment_group_name
}

output "service_role_arn" {
  description = "IAM role ARN used by CodeDeploy"
  value       = aws_iam_role.codedeploy.arn
}
