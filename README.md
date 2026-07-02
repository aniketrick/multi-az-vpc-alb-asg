# Multi-AZ VPC with ALB and Auto Scaling

A free-tier-conscious AWS infrastructure project that demonstrates resilient VPC design, subnet segmentation, load balancing, Auto Scaling, EC2 bootstrapping, security groups, and Terraform-based delivery.

> Cost safety: this repository is designed with a `cost_safe_mode` switch. By default, NAT Gateway is disabled and EC2 capacity is set conservatively. Application Load Balancer and public IPv4 usage can still create charges depending on your AWS account/free-tier plan, so deploy only briefly and destroy after screenshots/testing.

## Architecture

```text
Internet
  |
  v
Application Load Balancer (public subnets, 2 AZs)
  |
  v
Auto Scaling Group (EC2 web instances)
  |
  v
Simple Python HTTP app installed by user_data
```

The VPC contains:

- 2 public subnets across 2 Availability Zones
- 2 private subnets across 2 Availability Zones
- Internet Gateway
- Public route table
- Private route tables
- Optional NAT Gateway, disabled by default to avoid continuous hourly charges
- Application Load Balancer
- Auto Scaling Group
- Launch Template
- Security groups with least-required inbound traffic
- CloudWatch CPU alarm

## Why this project matters

This project demonstrates practical AWS networking and high-availability design. It answers common Cloud Engineer and Platform Engineer interview questions around VPC layout, public/private subnet segmentation, ALB routing, Auto Scaling, security groups, route tables, availability zones, and cost-aware infrastructure.

## Repository structure

```text
terraform/
  environments/dev/
  modules/network/
  modules/security/
  modules/compute/
  modules/alb/
app/
docs/
scripts/
.github/workflows/
```

## Free-tier-first choices

- Uses `t2.micro` by default.
- Uses Amazon Linux 2023 AMI via SSM parameter.
- NAT Gateway is disabled by default.
- Desired capacity is set to 1 by default to reduce EC2 usage.
- ALB is included for realism, but should be destroyed quickly after testing because ALB hours are billable.

## Prerequisites

- AWS CLI configured
- Terraform >= 1.5
- GitHub repository

Check identity before deploying:

```bash
aws sts get-caller-identity
aws configure get region
```

## Local validation

```bash
cd terraform/environments/dev
terraform init -backend=false
terraform fmt -recursive
terraform validate
```

## Deploy

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

Type `yes` when prompted.

After deploy:

```bash
terraform output
```

Open the `alb_dns_name` output in your browser.

## Test

```bash
curl http://$(terraform output -raw alb_dns_name)
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $(terraform output -raw autoscaling_group_name)
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw target_group_arn)
```

## Cleanup

Destroy resources immediately after testing:

```bash
cd terraform/environments/dev
terraform destroy
```

Type `yes`.

Confirm cleanup:

```bash
aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(LoadBalancerName, 'multi-az-vpc')].[LoadBalancerName,DNSName]" --output table
aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?contains(AutoScalingGroupName, 'multi-az-vpc')].[AutoScalingGroupName]" --output table
aws ec2 describe-instances --filters "Name=tag:Project,Values=multi-az-vpc-alb-asg" --query "Reservations[].Instances[].[InstanceId,State.Name]" --output table
```

## Screenshots to capture

- Terraform apply success
- VPC/subnets route table view
- ALB target group healthy targets
- Browser showing app via ALB DNS name
- Auto Scaling Group instance view
- CloudWatch CPU alarm
- Terraform destroy success

## Resume bullet

Built a cost-conscious Multi-AZ AWS web platform using Terraform, with a segmented VPC, public/private subnets, Application Load Balancer, Auto Scaling Group, EC2 launch template, security groups, CloudWatch alarming and automated cleanup.
