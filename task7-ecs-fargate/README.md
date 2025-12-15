# Task 7: Strapi on AWS ECS Fargate

Deploy Strapi on AWS ECS Fargate with Terraform and GitHub Actions CI/CD.

## Architecture (Simplified - No ALB/CloudWatch)
- **ECS Fargate**: Serverless containers with public IP
- **RDS PostgreSQL**: Managed database
- **ECR**: Docker image registry
- **VPC**: Custom networking with public/private subnets
- **NAT Gateway**: For outbound internet access

## CI/CD Workflows
1. **CI** (`ecs-ci.yml`): Build, tag, push Docker image to ECR
2. **CD** (`ecs-cd.yml`): Update ECS task definition and deploy

## Setup
```bash
cd task7-ecs-fargate/terraform
terraform init
terraform apply
```

## Deploy
Push code to trigger automated deployment:
```bash
git push origin Arman_Bisht_v2
```

## Access
Get task public IP from AWS ECS console or GitHub Actions output
Application URL: `http://<task-public-ip>:1337`
Admin: `http://<task-public-ip>:1337/admin`

## Cost: ~$31/month (Using Default VPC)
- ECS Fargate (2 tasks): $15
- RDS db.t3.micro: $15
- ECR: $1
- Data Transfer: Free tier
