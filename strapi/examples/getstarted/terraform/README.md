# Terraform Configuration for Strapi EC2 Deployment

## Quick Start

```bash
# 1. Initialize Terraform
terraform init

# 2. Create your variables file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 3. Preview changes
terraform plan

# 4. Deploy
terraform apply

# 5. Get outputs
terraform output

# 6. Cleanup (when done)
terraform destroy
```

## Files

- **main.tf** - Main infrastructure configuration (VPC, EC2, Security Group)
- **variables.tf** - Input variables definition
- **outputs.tf** - Output values after deployment
- **user_data.sh** - Script that runs on EC2 instance startup
- **terraform.tfvars.example** - Example configuration (copy to terraform.tfvars)

## Required Variables

You must set these in terraform.tfvars:

- `key_name` - Your AWS SSH key pair name
- `docker_image` - Your Docker image (e.g., username/strapi-app:latest)

## Optional Variables

- `aws_region` - AWS region (default: us-east-1)
- `instance_type` - EC2 instance type (default: t3.medium)

## What Gets Created

- VPC with CIDR 10.0.0.0/16
- Public subnet
- Internet gateway
- Route table
- Security group (ports 22, 80, 1337)
- EC2 instance with Docker and Strapi

## After Deployment

Access your Strapi application at:
```
http://YOUR_INSTANCE_IP:1337
```

SSH into your instance:
```bash
ssh -i your-key.pem ec2-user@YOUR_INSTANCE_IP
```

## Troubleshooting

Check container logs:
```bash
ssh -i your-key.pem ec2-user@YOUR_INSTANCE_IP
docker logs strapi-app
```

Restart container:
```bash
docker restart strapi-app
```
