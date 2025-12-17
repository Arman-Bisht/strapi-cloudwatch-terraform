# Task 8: CloudWatch Monitoring for ECS Fargate

## Overview
This task adds comprehensive CloudWatch monitoring to the Strapi ECS Fargate deployment, including logging, metrics, dashboards, and alarms.

## What's Included

### 1. CloudWatch Logs
- **Log Group**: `/ecs/strapi`
- **Retention**: 7 days
- **Stream Prefix**: `ecs/strapi`
- **Purpose**: Captures all container stdout/stderr logs

### 2. Container Insights
- **Enabled on ECS Cluster**
- **Metrics Collected**:
  - CPU Utilization (Average & Maximum)
  - Memory Utilization (Average & Maximum)
  - Task Count
  - Network In/Out (Rx/Tx Bytes)

### 3. CloudWatch Dashboard
- **Name**: `arman-strapi-ecs-dashboard`
- **Widgets**:
  - CPU Utilization (Average & Max)
  - Memory Utilization (Average & Max)
  - Task Count
  - Network In/Out

### 4. CloudWatch Alarms
Three alarms configured:

#### High CPU Alarm
- **Name**: `arman-strapi-ecs-high-cpu`
- **Threshold**: 80% CPU utilization
- **Evaluation**: 2 periods of 5 minutes
- **Action**: Alert when CPU exceeds threshold

#### High Memory Alarm
- **Name**: `arman-strapi-ecs-high-memory`
- **Threshold**: 80% memory utilization
- **Evaluation**: 2 periods of 5 minutes
- **Action**: Alert when memory exceeds threshold

#### Task Health Check Alarm
- **Name**: `arman-strapi-ecs-task-count-low`
- **Threshold**: Less than 1 running task
- **Evaluation**: 1 period of 1 minute
- **Action**: Alert when no tasks are running

## Infrastructure Files

### New Files Created
- `terraform/cloudwatch.tf` - CloudWatch resources (logs, dashboard, alarms)

### Modified Files
- `terraform/ecs.tf` - Added Container Insights and log configuration
- `terraform/iam.tf` - Added CloudWatch permissions
- `terraform/outputs.tf` - Added CloudWatch outputs

## Deployment

### Apply Terraform Changes
```bash
cd task7-ecs-fargate/terraform
terraform init
terraform plan
terraform apply
```

### View CloudWatch Resources

#### View Logs
```bash
# Tail logs in real-time
aws logs tail /ecs/strapi --follow --region ap-south-1

# View specific log stream
aws logs get-log-events \
  --log-group-name /ecs/strapi \
  --log-stream-name ecs/strapi/strapi/TASK_ID \
  --region ap-south-1
```

#### View Dashboard
```bash
# Get dashboard URL
terraform output cloudwatch_dashboard_url

# Or access via AWS Console:
# CloudWatch → Dashboards → arman-strapi-ecs-dashboard
```

#### View Alarms
```bash
# List all alarms
aws cloudwatch describe-alarms \
  --alarm-name-prefix arman-strapi-ecs \
  --region ap-south-1

# Check alarm state
aws cloudwatch describe-alarms \
  --alarm-names arman-strapi-ecs-high-cpu \
  --region ap-south-1
```

#### View Metrics
```bash
# Get CPU utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ClusterName,Value=arman-strapi-ecs-cluster Name=ServiceName,Value=arman-strapi-ecs-service \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average \
  --region ap-south-1

# Get memory utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name MemoryUtilization \
  --dimensions Name=ClusterName,Value=arman-strapi-ecs-cluster Name=ServiceName,Value=arman-strapi-ecs-service \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average \
  --region ap-south-1
```

## Monitoring Best Practices

### 1. Log Analysis
- Check logs regularly for errors and warnings
- Use CloudWatch Insights for log queries
- Set up log filters for specific error patterns

### 2. Metrics Monitoring
- Monitor CPU/Memory trends over time
- Set appropriate alarm thresholds based on your workload
- Review network metrics for unusual traffic patterns

### 3. Alarm Configuration
- Add SNS topics to alarm actions for notifications
- Configure email/SMS alerts for critical alarms
- Test alarms to ensure they trigger correctly

### 4. Dashboard Usage
- Review dashboard daily for anomalies
- Customize widgets based on your needs
- Share dashboard with team members

## Cost Considerations

### CloudWatch Costs
- **Logs**: $0.50 per GB ingested, $0.03 per GB stored
- **Metrics**: First 10 custom metrics free, $0.30 per metric thereafter
- **Dashboards**: First 3 dashboards free, $3 per dashboard per month
- **Alarms**: $0.10 per alarm per month

### Estimated Monthly Cost
- Logs (1GB/day): ~$15
- Container Insights: ~$5
- Dashboard: Free (first 3)
- Alarms (3): $0.30
- **Total**: ~$20/month

### Cost Optimization
- Reduce log retention period (currently 7 days)
- Filter logs to reduce ingestion
- Use metric filters instead of custom metrics
- Delete unused dashboards and alarms

## Troubleshooting

### Logs Not Appearing
1. Check IAM permissions for CloudWatch Logs
2. Verify log group exists: `aws logs describe-log-groups --region ap-south-1`
3. Check ECS task definition has correct log configuration
4. Ensure task is running: `aws ecs list-tasks --cluster arman-strapi-ecs-cluster --region ap-south-1`

### Metrics Not Showing
1. Verify Container Insights is enabled on cluster
2. Wait 5-10 minutes for metrics to appear
3. Check ECS service is running tasks
4. Verify correct dimensions in metric queries

### Alarms Not Triggering
1. Check alarm state: `aws cloudwatch describe-alarms`
2. Verify metric data is being collected
3. Review alarm threshold and evaluation periods
4. Check alarm actions are configured (SNS topics)

## Next Steps

### Optional Enhancements
1. **Add SNS Notifications**
   - Create SNS topic for alarm notifications
   - Subscribe email/SMS to topic
   - Update alarm actions to use SNS topic

2. **Custom Metrics**
   - Add application-level metrics
   - Monitor API response times
   - Track custom business metrics

3. **Log Insights Queries**
   - Create saved queries for common log searches
   - Set up scheduled queries for reports
   - Export query results to S3

4. **Advanced Dashboards**
   - Add more widgets for detailed metrics
   - Create separate dashboards for different teams
   - Use CloudWatch Contributor Insights

## References
- [CloudWatch Logs Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/)
- [Container Insights Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html)
- [CloudWatch Alarms Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html)
- [ECS CloudWatch Metrics](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cloudwatch-metrics.html)
