# Strapi Local Setup - DevOps Intern Task

## � CreateSd By

**Name**: Arman Bisht  
**Role**: DevOps Intern  
**Date**: December 3, 2025

---

## ✅ Tasks Completed

### Task 1: Strapi Local Setup
- ✓ Cloned official Strapi repository
- ✓ Installed dependencies and built project
- ✓ Started development server
- ✓ Created sample content and uploaded media

### Task 2: Docker Setup
- ✓ Created Dockerfile for Strapi application
- ✓ Built and tested Docker image locally
- ✓ Documented Docker setup process
- ✓ See: `TASK2_DOCKER_SUMMARY.md`

### Task 3: Docker Compose Multi-Container Setup
- ✓ Created docker-compose.yml with PostgreSQL
- ✓ Configured Nginx reverse proxy
- ✓ Set up networking between containers
- ✓ Documented in `strapi/examples/getstarted/`

### Task 4: Docker Deep Dive Documentation
- ✓ Explained Docker vs VMs
- ✓ Documented Docker architecture
- ✓ Covered Dockerfile, networking, volumes
- ✓ See: `strapi/examples/getstarted/Task_4_docker.md`

### Task 5: AWS EC2 Deployment with Terraform
- ✓ Automated infrastructure with Terraform
- ✓ Deployed Strapi on EC2 using Docker
- ✓ Configured VPC, Security Groups, and networking
- ✓ See: `strapi/examples/getstarted/TASK5_README.md`

### Task 6: GitHub Actions CI/CD Pipeline
- ✓ Created CI workflow for Docker image builds
- ✓ Automated Docker image push to AWS ECR
- ✓ Created CD workflow for Terraform deployments
- ✓ Deployed EC2 instance with IAM role for ECR access
- ✓ Configured manual workflow triggers for infrastructure management
- ✓ See: `.github/workflows/` and `strapi/examples/getstarted/TASK6_README.md`

#### CI/CD Pipeline Proof

**CI Workflow - Automated Docker Build & Push:**
![CI Build Success](CI_Build.png)

**CD Workflow - Terraform Deployment:**
![CD Deployment Success](CD_deployment.png)

### Task 7, 8 & 9: ECS Fargate Spot with CI/CD, ALB, and CloudWatch Monitoring
- ✓ Deployed Strapi on AWS ECS Fargate Spot (70% cost savings)
- ✓ Infrastructure managed entirely via Terraform
- ✓ Automated CI/CD pipeline with GitHub Actions
- ✓ Docker images automatically built, tagged, and pushed to ECR
- ✓ ECS task definitions automatically updated on code push
- ✓ **Fargate Spot** with automatic fallback to regular Fargate
- ✓ **Application Load Balancer (ALB)** for high availability and traffic management
- ✓ Multi-AZ deployment with automatic health checks
- ✓ CloudWatch Logs for application logging
- ✓ CloudWatch Container Insights for metrics (CPU, Memory, Network)
- ✓ CloudWatch Dashboard with 8 widgets (4 ECS + 4 ALB metrics)
- ✓ CloudWatch Alarms for CPU, memory, task health, ALB health, and response time
- ✓ Production-ready architecture with zero-downtime deployments
- ✓ Highly cost-optimized architecture (~$33/month with Spot, ALB, and monitoring)
- ✓ Complete automation - zero manual deployment steps
- ✓ See: `ecs-fargate/` and `.github/workflows/ecs-ci.yml`

### Task 10: Blue/Green Deployment with AWS CodeDeploy
- ✓ Implemented Blue/Green deployment strategy for zero-downtime updates
- ✓ Configured AWS CodeDeploy with ECS integration
- ✓ Created Blue and Green target groups for traffic switching
- ✓ Deployed CodeDeploy application and deployment group
- ✓ **Canary Deployment Strategy**: CodeDeployDefault.ECSCanary10Percent5Minutes
  - 10% traffic shifted to new version initially
  - 5-minute monitoring period before full rollout
  - Automatic rollback on failure or alarm triggers
- ✓ CloudWatch alarms integrated for automatic rollback
- ✓ ECS service configured with CODE_DEPLOY controller
- ✓ Load balancer info with target_group_pair_info for ECS
- ✓ IAM roles and policies for CodeDeploy ECS permissions
- ✓ Successfully tested Blue/Green deployment (Deployment ID: d-DN6B7QROF)
- ✓ Production-ready with instant rollback capability
- ✓ See: `ecs-fargate/BLUE_GREEN_DEPLOYMENT.md` and `ecs-fargate/terraform/codedeploy.tf`

**Live Deployment**: http://arman-strapi-ecs-alb-356414694.ap-south-1.elb.amazonaws.com  
**Admin Panel**: http://arman-strapi-ecs-alb-356414694.ap-south-1.elb.amazonaws.com/admin  
**Repository**: https://github.com/Arman-Bisht/strapi-cloudwatch-terraform

---

## 🚀 Setup Steps

### 1. Clone Repository

```bash
git clone https://github.com/strapi/strapi.git
cd strapi
```

### 2. Install Dependencies

```bash
yarn install
```

### 3. Build Project

```bash
yarn setup
```

### 4. Run Development Server

```bash
npm run develop
```

Access admin panel at: `http://localhost:1337/admin`

---

## 📝 Sample Content Created

### Content Entry Details

**Title**: Strapi Local Setup and PR Preparation

**Content**: Cloned the official Strapi repository, installed Node dependencies using yarn, created my new feature branch (e.g., feature/ArmanBisht), successfully started the development server, and created this sample content entry to verify functionality.

**Team Member Component**:

- **Name**: Arman
- **Role**: DevOps Intern
- **Bio**: Completed the initial task of setting up the local Strapi development environment and verifying the Content Manager functionality by creating a sample content entry.

**Cover Image**: Uploaded to Media Library (Strapi Local Setup image)

---

## 📁 Project Structure

```
Script-Smiths/
├── README.md                           # This file
├── TASK2_DOCKER_SUMMARY.md            # Task 2 documentation
├── .github/
│   └── workflows/
│       ├── ci.yml                      # Task 6: CI workflow
│       ├── terraform.yml               # Task 6: CD workflow
│       ├── ecs-ci.yml                  # Task 7: ECS CI/CD workflow
│       └── ecs-cd.yml                  # Task 7: Manual deployment
├── ecs-fargate/                        # Task 7, 8, 9 & 10: ECS Fargate with ALB, CloudWatch & Blue/Green
│   ├── Dockerfile                      # Strapi container image
│   ├── package.json                    # Application dependencies
│   ├── config/                         # Strapi configuration
│   ├── src/                            # Application code
│   ├── README.md                       # Deployment documentation
│   ├── TASK8_CLOUDWATCH.md            # CloudWatch monitoring guide
│   ├── ALB_IMPLEMENTATION.md          # ALB setup documentation
│   ├── FARGATE_SPOT.md                # Fargate Spot implementation guide
│   ├── BLUE_GREEN_DEPLOYMENT.md       # Blue/Green deployment guide
│   ├── LOOM_SCRIPT_3MIN.md            # Video presentation script
│   ├── appspec.yaml                    # CodeDeploy application specification
│   ├── deployment.json                 # CodeDeploy deployment configuration
│   ├── new-task-def.json              # Updated ECS task definition
│   └── terraform/                      # ECS infrastructure
│       ├── main.tf                     # Provider & backend
│       ├── ecr.tf                      # Container registry
│       ├── ecs.tf                      # Fargate cluster & service with Blue/Green
│       ├── alb.tf                      # Application Load Balancer with dual target groups
│       ├── codedeploy.tf               # Blue/Green deployment with CodeDeploy
│       ├── iam.tf                      # Permissions & roles
│       ├── security_groups.tf          # Network security
│       ├── cloudwatch.tf               # Monitoring & alarms
│       ├── outputs.tf                  # Infrastructure outputs
│       └── variables.tf                # Configuration
└── strapi/
    └── examples/
        └── getstarted/
            ├── Dockerfile.ci               # CI/CD Docker image
            ├── docker-compose.yml          # Multi-container setup
            ├── nginx.conf                  # Nginx configuration
            ├── Task_4_docker.md           # Docker deep dive
            ├── TASK5_README.md            # EC2 deployment guide
            ├── TASK6_README.md            # CI/CD pipeline guide
            └── terraform/                  # Infrastructure as code
                ├── main.tf
                ├── variables.tf
                ├── outputs.tf
                └── user_data.sh
```

---

## 🔧 Technologies Used

- **Strapi**: Headless CMS
- **Docker**: Containerization
- **Docker Compose**: Multi-container orchestration
- **PostgreSQL**: Database (Task 3-6)
- **SQLite**: Database (Task 7)
- **Nginx**: Reverse proxy
- **Terraform**: Infrastructure as Code
- **AWS EC2**: Cloud deployment (Task 5-6)
- **AWS ECS Fargate Spot**: Serverless containers with 70% cost savings (Task 7-9)
- **AWS ECR**: Container registry
- **AWS CloudWatch**: Logging, metrics, dashboards, and alarms (Task 8)
- **GitHub Actions**: CI/CD automation
- **Amazon Linux 2023**: Operating system

---

## 📚 Resources

- [Strapi Documentation](https://docs.strapi.io)
- [GitHub Repository](https://github.com/strapi/strapi)

---

**Strapi Version**: v5.x  
**Node Version**: v20.14.0
