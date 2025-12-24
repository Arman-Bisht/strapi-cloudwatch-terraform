# Task 11: GitHub Actions Blue/Green Deployment Pipeline

## Overview

This task implements a comprehensive GitHub Actions workflow that automates the entire Blue/Green deployment process for our Strapi application on AWS ECS Fargate using AWS CodeDeploy.

## 🎯 Objectives

1. **Automated Docker Build & Push**: Build Docker images tagged with commit SHA and push to Amazon ECR
2. **Dynamic Task Definition Updates**: Update ECS Task Definition with new image tags automatically
3. **Blue/Green Deployment**: Trigger AWS CodeDeploy for zero-downtime deployments
4. **Deployment Monitoring**: Monitor deployment status and handle failures
5. **Automatic Rollback**: Rollback on deployment failures
6. **Health Checks**: Verify application health post-deployment
7. **Resource Cleanup**: Clean up old task definitions and ECR images

## 🏗️ Workflow Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Build & Push  │───▶│   Deploy with    │───▶│ Post-Deployment │
│   Docker Image  │    │   CodeDeploy     │    │  Verification   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                        │
         ▼                        ▼                        ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ • Build image   │    │ • Update task    │    │ • Health checks │
│ • Tag with SHA  │    │   definition     │    │ • Rollback on   │
│ • Push to ECR   │    │ • Create AppSpec │    │   failure       │
│ • Set outputs   │    │ • Trigger deploy │    │ • Final report  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
                    ┌──────────────────┐
                    │    Cleanup       │
                    │ • Old task defs  │
                    │ • Old ECR images │
                    └──────────────────┘
```

## 📋 Workflow Jobs

### Job 1: Build and Push Docker Image
- **Purpose**: Build Docker image and push to ECR with commit SHA tag
- **Key Steps**:
  - Checkout code
  - Configure AWS credentials
  - Login to Amazon ECR
  - Build Docker image with commit SHA tag
  - Push image to ECR (both SHA and latest tags)
  - Set outputs for downstream jobs

### Job 2: Blue/Green Deployment with CodeDeploy
- **Purpose**: Deploy new version using Blue/Green strategy
- **Key Steps**:
  - Download current task definition
  - Update task definition with new image URI
  - Register new task definition revision
  - Create AppSpec file for CodeDeploy
  - Trigger CodeDeploy Blue/Green deployment
  - Monitor deployment status (up to 20 minutes)
  - Handle deployment failures

### Job 3: Post-Deployment Verification
- **Purpose**: Verify deployment success and handle rollbacks
- **Key Steps**:
  - Perform health checks on ALB endpoint
  - Verify application is responding correctly
  - Initiate rollback if health checks fail
  - Generate final deployment report

### Job 4: Cleanup
- **Purpose**: Clean up old resources to optimize costs
- **Key Steps**:
  - Remove old task definition revisions (keep last 5)
  - Delete old ECR images (keep last 10)
  - Generate cleanup summary

## 🔧 Configuration

### Environment Variables
```yaml
env:
  AWS_REGION: ap-south-1
  ECR_REPOSITORY: arman-strapi-fargate
  ECS_CLUSTER: arman-strapi-ecs-cluster
  ECS_SERVICE: arman-strapi-ecs-service
  ECS_TASK_DEFINITION: arman-strapi-ecs-task
  CODEDEPLOY_APPLICATION: arman-strapi-codedeploy-app
  CODEDEPLOY_DEPLOYMENT_GROUP: arman-strapi-deployment-group
  CONTAINER_NAME: strapi
```

### Required GitHub Secrets
- `AWS_ACCESS_KEY_ID`: AWS access key for deployment
- `AWS_SECRET_ACCESS_KEY`: AWS secret key for deployment

### Trigger Conditions
- **Push to branches**: `main`, `Arman_Bisht_v2`
- **Path filters**: Changes to `ecs-fargate/**` or workflow file
- **Manual trigger**: `workflow_dispatch` with force deploy option

## 🚀 Deployment Process

### 1. Image Building
```bash
# Build with commit SHA tag
docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$GITHUB_SHA .

# Tag as latest
docker tag $ECR_REGISTRY/$ECR_REPOSITORY:$GITHUB_SHA \
           $ECR_REGISTRY/$ECR_REPOSITORY:latest

# Push both tags
docker push $ECR_REGISTRY/$ECR_REPOSITORY:$GITHUB_SHA
docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
```

### 2. Task Definition Update
```bash
# Download current task definition
aws ecs describe-task-definition \
  --task-definition $ECS_TASK_DEFINITION \
  --query taskDefinition > current-task-definition.json

# Update image URI
jq --arg IMAGE "$NEW_IMAGE_URI" \
   '.containerDefinitions[0].image = $IMAGE' \
   current-task-definition.json > updated-task-definition.json

# Register new revision
aws ecs register-task-definition \
  --cli-input-json file://new-task-definition.json
```

### 3. AppSpec Creation
```yaml
version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: "arn:aws:ecs:region:account:task-definition/family:revision"
        LoadBalancerInfo:
          ContainerName: "strapi"
          ContainerPort: 1337
Hooks:
  - BeforeInstall: "BeforeInstall"
  - AfterInstall: "AfterInstall"
  - AfterAllowTestTraffic: "AfterAllowTestTraffic"
  - BeforeAllowTraffic: "BeforeAllowTraffic"
  - AfterAllowTraffic: "AfterAllowTraffic"
```

### 4. CodeDeploy Deployment
```bash
# Create deployment
aws deploy create-deployment \
  --application-name $CODEDEPLOY_APPLICATION \
  --deployment-group-name $CODEDEPLOY_DEPLOYMENT_GROUP \
  --description "GitHub Actions Blue/Green deployment" \
  --revision revisionType=AppSpecContent,appSpecContent='{
    "content": "base64-encoded-appspec"
  }'
```

## 📊 Monitoring and Verification

### Deployment Status Monitoring
- **Timeout**: 20 minutes maximum
- **Check Interval**: 30 seconds
- **Status Tracking**: InProgress → Succeeded/Failed/Stopped
- **Error Handling**: Automatic failure detection and reporting

### Health Checks
- **Endpoint**: ALB DNS name
- **Method**: HTTP GET request
- **Success Criteria**: HTTP 200 or 302 response
- **Retry Logic**: 10 attempts with 30-second intervals
- **Timeout**: 5 minutes total

### Rollback Strategy
- **Trigger**: Deployment failure or health check failure
- **Method**: AWS CodeDeploy automatic rollback
- **Action**: Stop current deployment and revert to previous version

## 🧹 Resource Management

### Task Definition Cleanup
- **Retention**: Keep last 5 active revisions
- **Action**: Deregister older revisions
- **Frequency**: After successful deployments

### ECR Image Cleanup
- **Retention**: Keep last 10 images
- **Action**: Delete older images by digest
- **Frequency**: After successful deployments

## 📈 Benefits

### 1. Zero-Downtime Deployments
- Blue/Green strategy ensures no service interruption
- Traffic is gradually shifted from old to new version
- Automatic rollback on failures

### 2. Automated Pipeline
- No manual intervention required
- Consistent deployment process
- Reduced human error

### 3. Comprehensive Monitoring
- Real-time deployment status tracking
- Health verification post-deployment
- Detailed logging and reporting

### 4. Cost Optimization
- Automatic cleanup of old resources
- Efficient resource utilization
- Reduced storage costs

### 5. Reliability
- Automatic rollback on failures
- Multiple verification layers
- Comprehensive error handling

## 🔍 Troubleshooting

### Common Issues

#### 1. ECR Authentication Failure
```bash
# Solution: Verify AWS credentials and ECR permissions
aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $ECR_REGISTRY
```

#### 2. Task Definition Registration Failure
```bash
# Solution: Check task definition format and IAM permissions
aws ecs register-task-definition --cli-input-json file://task-def.json --dry-run
```

#### 3. CodeDeploy Deployment Failure
```bash
# Solution: Verify CodeDeploy configuration and service permissions
aws deploy get-deployment --deployment-id $DEPLOYMENT_ID
```

#### 4. Health Check Failures
```bash
# Solution: Check ALB configuration and target group health
aws elbv2 describe-target-health --target-group-arn $TARGET_GROUP_ARN
```

## 📝 Usage Instructions

### 1. Prerequisites
- AWS infrastructure deployed (ECS, ALB, CodeDeploy)
- GitHub repository with proper secrets configured
- ECR repository created and accessible

### 2. Triggering Deployment
```bash
# Automatic trigger on push
git push origin main

# Manual trigger via GitHub UI
# Go to Actions → ECS Blue/Green Deployment → Run workflow
```

### 3. Monitoring Deployment
- Check GitHub Actions workflow progress
- Monitor AWS CodeDeploy console
- Verify application health via ALB endpoint

### 4. Rollback (if needed)
```bash
# Manual rollback via AWS CLI
aws deploy stop-deployment --deployment-id $DEPLOYMENT_ID --auto-rollback-enabled
```

## 🎯 Success Metrics

- **Deployment Time**: < 10 minutes average
- **Success Rate**: > 95% successful deployments
- **Rollback Time**: < 2 minutes when needed
- **Zero Downtime**: 100% uptime during deployments

## 🔗 Related Files

- **Workflow**: `.github/workflows/ecs-blue-green-deploy.yml`
- **AppSpec**: `ecs-fargate/appspec.yaml`
- **Task Definitions**: `ecs-fargate/current-task-def.json`, `ecs-fargate/new-task-def.json`
- **Terraform**: `ecs-fargate/terraform/codedeploy.tf`

## 📚 References

- [AWS CodeDeploy Blue/Green Deployments](https://docs.aws.amazon.com/codedeploy/latest/userguide/applications-create-blue-green.html)
- [GitHub Actions for AWS](https://github.com/aws-actions)
- [ECS Task Definition Parameters](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html)
- [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)

---

**Task 11 Status**: ✅ **COMPLETED**
- Comprehensive GitHub Actions workflow implemented
- Blue/Green deployment with CodeDeploy configured
- Monitoring, health checks, and rollback mechanisms in place
- Resource cleanup and cost optimization included