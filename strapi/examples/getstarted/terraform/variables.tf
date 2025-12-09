# Variables for Terraform Configuration

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"  # Free Tier eligible - 750 hours/month for 12 months
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "docker_image" {
  description = "Docker image to deploy (Docker Hub or ECR)"
  type        = string
  default     = "your-dockerhub-username/strapi-app:latest"
}
