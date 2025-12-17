# Outputs

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.strapi.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.strapi.name
}

output "access_instructions" {
  description = "How to access the application"
  value       = "Get task public IP from ECS console or use AWS CLI to find running tasks"
}

# CloudWatch Outputs
output "cloudwatch_log_group" {
  description = "CloudWatch Log Group name"
  value       = aws_cloudwatch_log_group.ecs_strapi.name
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch Dashboard name"
  value       = aws_cloudwatch_dashboard.ecs_strapi.dashboard_name
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch Dashboard URL"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.ecs_strapi.dashboard_name}"
}

output "cloudwatch_alarms" {
  description = "CloudWatch Alarms created"
  value = {
    cpu_alarm    = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
    memory_alarm = aws_cloudwatch_metric_alarm.memory_high.alarm_name
    task_alarm   = aws_cloudwatch_metric_alarm.task_count_low.alarm_name
  }
}
