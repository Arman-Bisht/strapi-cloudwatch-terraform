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

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "application_url" {
  description = "Application URL"
  value       = "http://${aws_lb.main.dns_name}"
}

output "access_instructions" {
  description = "How to access the application"
  value       = "Access the application at: http://${aws_lb.main.dns_name}"
}

# Blue/Green Deployment Outputs
output "blue_target_group_arn" {
  description = "Blue target group ARN"
  value       = aws_lb_target_group.blue.arn
}

output "green_target_group_arn" {
  description = "Green target group ARN"
  value       = aws_lb_target_group.green.arn
}

output "codedeploy_app_name" {
  description = "CodeDeploy application name"
  value       = aws_codedeploy_app.strapi.name
}

output "codedeploy_deployment_group_name" {
  description = "CodeDeploy deployment group name"
  value       = aws_codedeploy_deployment_group.strapi.deployment_group_name
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
    cpu_alarm               = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
    memory_alarm            = aws_cloudwatch_metric_alarm.memory_high.alarm_name
    task_alarm              = aws_cloudwatch_metric_alarm.task_count_low.alarm_name
    alb_blue_unhealthy_alarm = aws_cloudwatch_metric_alarm.alb_unhealthy_hosts_blue.alarm_name
    alb_green_unhealthy_alarm = aws_cloudwatch_metric_alarm.alb_unhealthy_hosts_green.alarm_name
    alb_response_alarm      = aws_cloudwatch_metric_alarm.alb_target_response_time.alarm_name
  }
}
