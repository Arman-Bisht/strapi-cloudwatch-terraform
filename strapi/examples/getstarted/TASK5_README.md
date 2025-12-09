# Task 5: Deploy Strapi on EC2 using Terraform and Docker

## Overview

This task implements automated deployment of Strapi on AWS EC2 using Terraform for infrastructure as code and Docker for containerization.

## What Was Accomplished

✅ Automated AWS infrastructure deployment with Terraform  
✅ Deployed Strapi using official Docker image  
✅ Configured VPC, Security Groups, and EC2 instance  
✅ Automated setup with user_data script  
✅ Enabled SSH access (both .pem file and AWS Console)  
✅ Configured memory swap for better performance  

## Architecture

```
Developer → Terraform → AWS EC2 (t3.medium) → Docker → Strapi
                         ↓
                    VPC + Security Groups
```

**Components:**
- VPC with public subnet (10.0.0.0/16)
- Internet Gateway for external access
- Security Group (ports 22, 80, 1337)
- EC2 instance (Amazon Linux 2023, t3.medium)
- Docker with official Strapi image
- 2GB swap space for memory management

## Files Structure

```
getstarted/
├── terraform/
│   ├── main.tf                    # Infrastructure definition
│   ├── variables.tf               # Input variables
│   ├── outputs.tf                 # Output values
│   ├── user_data.sh              # EC2 startup script
│   ├── terraform.tfvars          # Your configuration
│   └── terraform.tfvars.example  # Configuration template
├── Dockerfile.production         # Production Dockerfile (not used)
└── TASK5_README.md              # This file
```

## Prerequisites

- AWS account with appropriate permissions
- AWS CLI configured (`aws configure`)
- Terraform >= 1.0 installed
- SSH key pair created in AWS (ap-south-1 region)

## Deployment Steps

### 1. Configure Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
aws_region    = "ap-south-1"
instance_type = "t3.medium"
key_name      = "Strapi-key"
docker_image  = "strapi/strapi:latest"
```

### 2. Deploy Infrastructure

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

### 3. Access Strapi

After deployment (wait 2-3 minutes for Docker to start):

- **Strapi URL**: http://YOUR_IP:1337
- **Admin Panel**: http://YOUR_IP:1337/admin

Get your IP from terraform output:
```bash
terraform output instance_public_ip
```

### 4. SSH Access

**Method 1: Using .pem file**
```bash
ssh -i Strapi-key.pem ec2-user@YOUR_IP
```

**Method 2: AWS Console**
- Go to EC2 Console → Instances
- Select instance → Connect → EC2 Instance Connect
- Username: `ec2-user`

## What the Deployment Does

The `user_data.sh` script automatically:

1. Updates system packages
2. Installs EC2 Instance Connect (for AWS Console SSH)
3. Creates 2GB swap space
4. Installs Docker
5. Pulls official Strapi image (~500MB)
6. Starts Strapi container with:
   - Port 1337 and 80 mapped
   - Auto-restart policy
   - Persistent volume for data
   - Required environment variables

## Monitoring

**Check container status:**
```bash
docker ps
docker logs strapi-app
docker stats
```

**System resources:**
```bash
htop
free -h
df -h
```

## Cost Estimate

- **t3.medium**: ~$0.042/hour (~$30/month)
- **EBS Storage (20GB)**: ~$2/month
- **Data Transfer**: First 15GB free

**For testing**: A few hours costs ~$0.20

## Cleanup

**Important**: Destroy resources when done to stop charges:

```bash
cd terraform
terraform destroy
```

Type `yes` when prompted. This removes all AWS resources.

## Troubleshooting

**Strapi not loading:**
- Wait 3-5 minutes after deployment
- Check Docker: `docker ps`
- Check logs: `docker logs strapi-app`

**SSH not working:**
- Verify key pair name matches in terraform.tfvars
- Check security group allows port 22
- Fix .pem permissions: `chmod 400 Strapi-key.pem`

**Container not starting:**
- SSH into instance
- Check logs: `docker logs strapi-app`
- Restart: `docker restart strapi-app`

## Key Decisions Made

**Why Official Strapi Image?**
- Much smaller (~500MB vs 4.18GB custom image)
- Faster deployment (2-3 minutes vs 10+ minutes)
- Maintained by Strapi team
- Production-ready

**Why t3.medium?**
- 4GB RAM provides comfortable headroom
- 2 vCPUs for good performance
- Can downgrade to t3.small later if needed
- Current usage: ~800MB RAM (plenty of room)

**Why Memory Swap?**
- Provides 2GB additional virtual memory
- Prevents out-of-memory crashes
- Improves stability on smaller instances

## Security Considerations

**Current Setup (Testing):**
- Ports 22, 80, 1337 open to 0.0.0.0/0
- Using default Strapi secrets

**For Production:**
- Restrict SSH to specific IPs
- Use AWS Secrets Manager for credentials
- Add SSL/TLS with Application Load Balancer
- Use RDS instead of SQLite
- Enable CloudWatch logging
- Implement backup strategy

## Next Steps (Optional)

1. Configure Strapi content types
2. Set up RDS PostgreSQL database
3. Add Application Load Balancer
4. Implement CI/CD pipeline
5. Configure custom domain
6. Add SSL certificate

## Success Criteria

✅ Infrastructure deployed via Terraform  
✅ Strapi accessible via browser  
✅ Docker container running  
✅ SSH access working  
✅ Automated deployment (no manual steps)  
✅ Documentation complete  

## Deployment Information

- **Region**: ap-south-1 (Mumbai)
- **Instance Type**: t3.medium (2 vCPU, 4GB RAM)
- **OS**: Amazon Linux 2023
- **Docker Image**: strapi/strapi:latest
- **Deployment Method**: Terraform + user_data
- **Date**: December 9, 2024

---

**Task Completed By**: Arman Bisht  
**Branch**: Arman_Bisht_v2  
**Status**: ✅ Complete and Tested
