# Required Permissions for Task 7 - ECS Fargate

## Quick Setup (Recommended)

### Option 1: Attach AWS Managed Policies (Easiest)
Attach these AWS managed policies to your IAM user `Arman1`:

1. **AmazonECS_FullAccess** - For ECS operations
2. **IAMFullAccess** - For creating IAM roles
3. **AmazonVPCFullAccess** - For VPC, subnets, NAT gateways
4. **AmazonRDSFullAccess** - For RDS database
5. **AmazonEC2ContainerRegistryFullAccess** - For ECR

**AWS Console Steps:**
```
1. Go to IAM Console
2. Click "Users" → Select "Arman1"
3. Click "Add permissions" → "Attach policies directly"
4. Search and select the 5 policies above
5. Click "Add permissions"
```

**AWS CLI Command:**
```bash
aws iam attach-user-policy --user-name Arman1 --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess
aws iam attach-user-policy --user-name Arman1 --policy-arn arn:aws:iam::aws:policy/IAMFullAccess
aws iam attach-user-policy --user-name Arman1 --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess
aws iam attach-user-policy --user-name Arman1 --policy-arn arn:aws:iam::aws:policy/AmazonRDSFullAccess
aws iam attach-user-policy --user-name Arman1 --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
```

---

## Option 2: Create Custom Policy (More Secure)

Use the `required-permissions.json` file in this directory.

**AWS Console Steps:**
```
1. Go to IAM Console → Policies
2. Click "Create policy"
3. Click "JSON" tab
4. Copy content from required-permissions.json
5. Click "Next"
6. Name: "ECSFargateDeploymentPolicy"
7. Click "Create policy"
8. Go to Users → Arman1 → Add permissions
9. Attach the new policy
```

**AWS CLI Command:**
```bash
# Create the policy
aws iam create-policy \
  --policy-name ECSFargateDeploymentPolicy \
  --policy-document file://required-permissions.json

# Attach to user
aws iam attach-user-policy \
  --user-name Arman1 \
  --policy-arn arn:aws:iam::891377350540:policy/ECSFargateDeploymentPolicy
```

---

## Verify Permissions

After attaching policies, verify you have access:

```bash
# Test ECS access
aws ecs list-clusters

# Test IAM access
aws iam list-roles

# Test RDS access
aws rds describe-db-instances

# Test ECR access
aws ecr describe-repositories
```

All commands should work without "AccessDenied" errors.

---

## Minimum Required Permissions Summary

| Service | Why Needed |
|---------|------------|
| **ECS** | Create cluster, tasks, services |
| **IAM** | Create roles for ECS tasks to pull images |
| **VPC** | Create networking (VPC, subnets, NAT) |
| **EC2** | Manage security groups, network interfaces |
| **RDS** | Create PostgreSQL database |
| **ECR** | Store Docker images |
| **S3** | Store Terraform state |

---

## Cost Warning

With full permissions, you can create expensive resources. Be careful with:
- NAT Gateways (~$32/month each)
- RDS instances (~$15/month)
- ECS Fargate tasks (~$15/month)

Always run `terraform destroy` when done testing!

---

## Troubleshooting

### "AccessDenied" errors during terraform apply
- Check you attached all required policies
- Wait 1-2 minutes for IAM changes to propagate
- Run `aws sts get-caller-identity` to confirm you're using correct account

### "User is not authorized to perform: iam:CreateRole"
- You need IAMFullAccess or the custom policy
- This is the most common blocker for ECS Fargate

### "User is not authorized to perform: ec2:CreateNatGateway"
- You need VPC full access
- NAT Gateway is required for private subnets to access internet
