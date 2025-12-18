# Application Load Balancer (ALB) Implementation

## Overview
Added Application Load Balancer to the ECS Fargate deployment for improved traffic management, health checks, and monitoring.

## What Was Added

### 1. **ALB Infrastructure** (`alb.tf`)

#### ALB Security Group
- Allows HTTP traffic (port 80) from anywhere
- Allows all outbound traffic
- Separate from ECS tasks security group

#### Application Load Balancer
- **Type**: Application Load Balancer (Layer 7)
- **Scheme**: Internet-facing
- **Subnets**: All default VPC subnets (multi-AZ)
- **Name**: `arman-strapi-ecs-alb`

#### Target Group
- **Port**: 1337 (Strapi default)
- **Protocol**: HTTP
- **Target Type**: IP (required for Fargate)
- **Health Check**:
  - Path: `/_health`
  - Interval: 30 seconds
  - Timeout: 5 seconds
  - Healthy threshold: 2 checks
  - Unhealthy threshold: 3 checks
  - Success codes: 200, 204

#### ALB Listener
- **Port**: 80 (HTTP)
- **Action**: Forward to Strapi target group
- Routes all traffic to ECS tasks

### 2. **ALB CloudWatch Alarms**

#### Unhealthy Hosts Alarm
- **Metric**: UnHealthyHostCount
- **Threshold**: > 0
- **Evaluation**: 2 periods of 1 minute
- **Purpose**: Alert when targets fail health checks

#### High Response Time Alarm
- **Metric**: TargetResponseTime
- **Threshold**: > 2 seconds
- **Evaluation**: 2 periods of 5 minutes
- **Purpose**: Alert when application is slow

### 3. **Updated ECS Service** (`ecs.tf`)

#### Load Balancer Integration
```hcl
load_balancer {
  target_group_arn = aws_lb_target_group.strapi.arn
  container_name   = "strapi"
  container_port   = 1337
}
```

- ECS service now registers tasks with ALB target group
- ALB performs health checks on tasks
- Unhealthy tasks are automatically replaced

### 4. **Updated Security Groups** (`security_groups.tf`)

#### ECS Tasks Security Group
- **Before**: Allowed port 1337 from anywhere (0.0.0.0/0)
- **After**: Allows port 1337 only from ALB security group
- **Benefit**: Tasks are not directly accessible from internet

### 5. **Enhanced CloudWatch Dashboard** (`cloudwatch.tf`)

Added 4 new widgets:

#### Widget 5: ALB Request Count
- Total HTTP requests received
- 5-minute intervals
- Shows traffic volume

#### Widget 6: ALB Response Time
- Average response time in seconds
- 5-minute intervals
- Monitors application performance

#### Widget 7: ALB Target Health
- Healthy vs Unhealthy host count
- 1-minute intervals
- Real-time health status

#### Widget 8: HTTP Response Codes
- 2XX (Success)
- 4XX (Client errors)
- 5XX (Server errors)
- 5-minute intervals
- Error rate monitoring

### 6. **Updated Outputs** (`outputs.tf`)

New outputs:
- `alb_dns_name` - ALB DNS endpoint
- `application_url` - Full HTTP URL
- `cloudwatch_alarms` - Now includes ALB alarms

## Benefits

### 1. **High Availability**
- Multi-AZ deployment
- Automatic failover between availability zones
- Health checks ensure only healthy tasks receive traffic

### 2. **Better Traffic Management**
- Single, stable DNS endpoint
- No need to track changing task IPs
- Connection draining during deployments

### 3. **Enhanced Monitoring**
- Request count and patterns
- Response time tracking
- HTTP status code distribution
- Target health visibility

### 4. **Improved Security**
- ECS tasks not directly exposed to internet
- Traffic only flows through ALB
- Can easily add WAF or SSL/TLS later

### 5. **Zero-Downtime Deployments**
- ALB drains connections from old tasks
- New tasks must pass health checks before receiving traffic
- Smooth rolling updates

## Architecture

```
Internet
   ↓
Application Load Balancer (Port 80)
   ↓
Target Group (Port 1337)
   ↓
ECS Fargate Tasks (Private)
   ↓
Strapi Application
```

## Access

### Before ALB
```
http://<task-public-ip>:1337/admin
```
- IP changes on every deployment
- Direct access to tasks
- No health checks

### After ALB
```
http://<alb-dns-name>/admin
```
- Stable DNS endpoint
- Automatic health checks
- Multi-AZ redundancy
- Better monitoring

## Cost Impact

### Additional Costs
- **ALB**: ~$16/month (base) + $0.008/LCU-hour
- **Data Processing**: ~$0.008 per GB
- **Estimated Total**: ~$18-20/month additional

### Total Infrastructure Cost
- ECS Fargate: ~$17/month
- CloudWatch: ~$5/month
- ALB: ~$18/month
- **Total**: ~$40/month

## Deployment

### Apply Changes
```bash
cd ecs-fargate/terraform
terraform init
terraform plan
terraform apply
```

### Get ALB URL
```bash
terraform output application_url
```

### Access Application
```bash
# Get the URL
ALB_URL=$(terraform output -raw application_url)

# Access admin panel
echo "$ALB_URL/admin"

# Test health endpoint
curl "$ALB_URL/_health"
```

## Monitoring

### View ALB Metrics
```bash
# Request count
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name RequestCount \
  --dimensions Name=LoadBalancer,Value=<alb-arn-suffix> \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum \
  --region ap-south-1

# Target health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn> \
  --region ap-south-1
```

### Dashboard
- Navigate to CloudWatch → Dashboards → `arman-strapi-ecs-dashboard`
- View all 8 widgets including ALB metrics

### Alarms
- 5 total alarms now:
  1. High CPU
  2. High Memory
  3. Low Task Count
  4. Unhealthy Targets (NEW)
  5. High Response Time (NEW)

## Health Check Endpoint

Strapi provides a built-in health check endpoint:
- **Path**: `/_health`
- **Response**: 204 No Content (healthy)
- **Purpose**: ALB uses this to determine task health

## Future Enhancements

### 1. HTTPS/SSL
```hcl
# Add ACM certificate
resource "aws_acm_certificate" "main" {
  domain_name       = "your-domain.com"
  validation_method = "DNS"
}

# Add HTTPS listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.main.arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi.arn
  }
}
```

### 2. WAF (Web Application Firewall)
```hcl
resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}
```

### 3. Custom Domain
- Register domain in Route 53
- Create A record pointing to ALB
- Add SSL certificate

### 4. SNS Notifications
```hcl
resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-alarms"
}

# Update alarm_actions in alarms
alarm_actions = [aws_sns_topic.alarms.arn]
```

## Troubleshooting

### Targets Not Healthy
1. Check security group allows ALB → ECS traffic
2. Verify health check path `/_health` is accessible
3. Check ECS task logs in CloudWatch
4. Ensure container is listening on port 1337

### High Response Time
1. Check ECS task CPU/Memory utilization
2. Review application logs for slow queries
3. Consider increasing task resources
4. Check database performance (if using RDS)

### 5XX Errors
1. Check ECS task logs for application errors
2. Verify environment variables are correct
3. Check database connectivity
4. Review CloudWatch metrics for patterns

## Summary

The ALB addition provides:
- ✅ Stable DNS endpoint
- ✅ Automatic health checks
- ✅ Multi-AZ high availability
- ✅ Enhanced monitoring (8 dashboard widgets)
- ✅ 5 CloudWatch alarms
- ✅ Better security (tasks not publicly accessible)
- ✅ Zero-downtime deployments
- ✅ Production-ready architecture

Cost: ~$18/month additional (~$40/month total)
