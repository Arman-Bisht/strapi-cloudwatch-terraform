# Variables for ECS Fargate Deployment

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "arman-strapi-ecs"
}

# VPC CIDR removed - using default VPC

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "arman-strapi-fargate"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "strapi"
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "fargate_cpu" {
  description = "Fargate CPU units"
  type        = string
  default     = "512"
}

variable "fargate_memory" {
  description = "Fargate memory in MB"
  type        = string
  default     = "1024"
}

variable "app_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}
