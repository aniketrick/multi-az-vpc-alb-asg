# Multi-AZ VPC with Application Load Balancer and Auto Scaling

A production-style AWS networking and compute project built with Terraform. This project provisions a highly available web application platform across multiple Availability Zones using a custom VPC, public and private subnets, an Application Load Balancer, EC2 Auto Scaling, security groups and CloudWatch monitoring.

The goal of this project is to demonstrate practical AWS infrastructure design, not just individual service knowledge. It shows how traffic flows from the internet into a resilient application layer, how subnets and route tables are structured, and how compute capacity can recover automatically through an Auto Scaling Group.

---

## Project Objective

This project answers a common Cloud Engineer interview question:

> Can you design and provision a resilient AWS web infrastructure using VPC networking, load balancing and Auto Scaling?

The architecture is designed to demonstrate:

* Multi-AZ VPC design
* Public and private subnet segmentation
* Internet-facing Application Load Balancer
* EC2 Auto Scaling Group
* Launch Template based instance provisioning
* Security group based traffic control
* CloudWatch alarm for operational visibility
* Terraform-based infrastructure as code
* Safe cleanup after testing to avoid unnecessary AWS charges

---

## Architecture

```text
Internet
   |
   v
Application Load Balancer
   |
   v
Target Group
   |
   v
Auto Scaling Group
   |
   v
EC2 Web Server running a simple Python HTTP app
```

The VPC is spread across two Availability Zones and includes:

```text
VPC
├── Public Subnet A
│   └── Application Load Balancer
├── Public Subnet B
│   └── Application Load Balancer
├── Private Subnet A
├── Private Subnet B
├── Internet Gateway
├── Public Route Table
├── Optional NAT Gateway
├── Launch Template
├── Auto Scaling Group
├── Target Group
└── CloudWatch Alarm
```

By default, the project keeps the deployment low-cost and free-tier conscious. NAT Gateway is disabled by default because it creates hourly charges.

---

## Technologies Used

| Area                   | Tools and Services                           |
| ---------------------- | -------------------------------------------- |
| Cloud Provider         | AWS                                          |
| Infrastructure as Code | Terraform                                    |
| Networking             | VPC, Subnets, Route Tables, Internet Gateway |
| Load Balancing         | Application Load Balancer                    |
| Compute                | EC2                                          |
| Scaling                | Auto Scaling Group                           |
| Observability          | CloudWatch Alarm                             |
| Security               | Security Groups, restricted inbound traffic  |
| App Runtime            | Python HTTP server through EC2 user data     |

---

## What This Project Demonstrates

This project demonstrates the core infrastructure skills expected from Cloud Engineer, Platform Engineer and SRE roles.

### AWS Networking

The project creates a custom VPC instead of using the default VPC. It includes public and private subnet design across two Availability Zones, route tables and an Internet Gateway.

### High Availability

The infrastructure is spread across multiple Availability Zones. The Application Load Balancer is placed across public subnets and the Auto Scaling Group can launch instances across the configured subnets.

### Load Balancing

An Application Load Balancer accepts HTTP traffic and forwards it to healthy EC2 targets through a Target Group.

### Auto Scaling

The EC2 application layer is managed by an Auto Scaling Group. If an instance fails, the ASG can replace it automatically.

### Infrastructure as Code

All infrastructure is defined using Terraform, making the environment repeatable, version-controlled and easier to review.

### Operational Awareness

A CloudWatch alarm is included to monitor high CPU usage on the Auto Scaling Group.

---

## Free Tier and Cost Awareness

This project was designed to be free-tier conscious, but not every AWS service used here is fully free.

Important cost notes:

* EC2 micro instances may be free-tier eligible depending on your AWS account and region.
* Application Load Balancer can create hourly charges.
* Public IPv4 addresses may create charges.
* NAT Gateway is disabled by default because it creates hourly and data processing charges.
* EBS, data transfer and CloudWatch usage may create small charges.
* Always run `terraform destroy` after testing.

To check free-tier eligible EC2 instance types in your selected region:

```bash
aws ec2 describe-instance-types \
  --filters Name=free-tier-eligible,Values=true \
  --query "InstanceTypes[*].InstanceType" \
  --output text | tr '\t' '\n' | sort
```

---

## Repository Structure

```text
multi-az-vpc-alb-asg/
├── .github/
│   └── workflows/
│       └── terraform-ci.yml
├── docs/
│   └── architecture.md
├── terraform/
│   ├── environments/
│   │   └── dev/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       └── terraform.tfvars.example
│   └── modules/
│       ├── networking/
│       ├── alb/
│       └── compute/
└── README.md
```

---

## Prerequisites

Before deploying, make sure you have:

* AWS CLI installed and configured
* Terraform installed
* A valid AWS account
* AWS credentials configured locally
* Permission to create VPC, EC2, ALB, Auto Scaling and CloudWatch resources

Check your AWS identity:

```bash
aws sts get-caller-identity
```

Check your configured region:

```bash
aws configure get region
```

This project was tested in:

```text
eu-west-2
```

---

## Deployment Steps

### 1. Clone the repository

```bash
git clone https://github.com/aniketrick/multi-az-vpc-alb-asg.git
cd multi-az-vpc-alb-asg
```

### 2. Go to the Terraform dev environment

```bash
cd terraform/environments/dev
```

### 3. Create a Terraform variables file

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit the values if needed:

```bash
nano terraform.tfvars
```

Recommended free-tier conscious settings:

```hcl
aws_region        = "eu-west-2"
project_name      = "multi-az-vpc"
environment       = "dev"
instance_type     = "t3.micro"
desired_capacity  = 1
min_size          = 1
max_size          = 2
enable_nat_gateway = false
```

Use the EC2 free-tier check command above to confirm the best instance type for your account and region.

---

## Terraform Commands

### Initialise Terraform

```bash
terraform init
```

### Format and validate

```bash
terraform fmt -recursive
terraform validate
```

### Preview the infrastructure

```bash
terraform plan
```

### Deploy

```bash
terraform apply
```

When prompted, type:

```text
yes
```

---

## Outputs

After a successful deployment, Terraform will show outputs similar to:

```text
alb_dns_name = "multi-az-vpc-alb-xxxxxxxx.eu-west-2.elb.amazonaws.com"
autoscaling_group_name = "multi-az-vpc-asg"
public_subnet_ids = [...]
private_subnet_ids = [...]
target_group_arn = "arn:aws:elasticloadbalancing:..."
```

---

## Testing the Application

Use the ALB DNS name from Terraform output:

```bash
curl http://$(terraform output -raw alb_dns_name)
```

Or open it in your browser:

```text
http://<alb_dns_name>
```

A successful response means:

```text
Internet → ALB → Target Group → EC2 application
```

is working.

---

## Check Target Group Health

Use the target group ARN from Terraform output:

```bash
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)
```

A healthy target should show:

```text
State: healthy
```

This proves the Application Load Balancer can successfully reach the EC2 instance.

---

## Check Auto Scaling Group

```bash
aws autoscaling describe-auto-scaling-groups \
  --query "AutoScalingGroups[?contains(AutoScalingGroupName, 'multi-az')].[AutoScalingGroupName,DesiredCapacity,MinSize,MaxSize]" \
  --output table
```

This confirms the Auto Scaling Group exists and is managing the desired number of instances.

---

## Check EC2 Instances

```bash
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=multi-az-vpc-alb-asg" \
  --query "Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,PrivateIpAddress]" \
  --output table
```

This confirms which EC2 instances were launched by the project.

---

## Check CloudWatch Alarm

```bash
aws cloudwatch describe-alarms \
  --query "MetricAlarms[?contains(AlarmName, 'multi-az-vpc')].[AlarmName,StateValue,MetricName,Threshold]" \
  --output table
```

The alarm may show:

```text
OK
```

or:

```text
INSUFFICIENT_DATA
```

`INSUFFICIENT_DATA` is normal shortly after deployment because CloudWatch may not have enough metric data yet.

---

## Cleanup

To avoid unnecessary AWS charges, destroy the infrastructure after testing.

From:

```bash
terraform/environments/dev
```

run:

```bash
terraform destroy
```

When prompted, type:

```text
yes
```

Confirm cleanup:

```bash
aws elbv2 describe-load-balancers \
  --query "LoadBalancers[?contains(LoadBalancerName, 'multi-az-vpc')].[LoadBalancerName,DNSName]" \
  --output table

aws autoscaling describe-auto-scaling-groups \
  --query "AutoScalingGroups[?contains(AutoScalingGroupName, 'multi-az-vpc')].[AutoScalingGroupName]" \
  --output table

aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=multi-az-vpc-alb-asg" \
  --query "Reservations[*].Instances[*].[InstanceId,State.Name]" \
  --output table
```

If no project resources appear, cleanup is complete.

---

## Common Issue: Instance Type Not Free-Tier Eligible

If Terraform fails with:

```text
The specified instance type is not eligible for Free Tier
```

check eligible instance types:

```bash
aws ec2 describe-instance-types \
  --filters Name=free-tier-eligible,Values=true \
  --query "InstanceTypes[*].InstanceType" \
  --output text | tr '\t' '\n' | sort
```

Then update:

```hcl
instance_type = "t3.micro"
```

or another free-tier eligible instance type shown by AWS.

Re-run:

```bash
terraform apply
```

---

## Common Issue: ALB Takes Time to Create

It is normal for the ALB and Auto Scaling Group to show:

```text
Still creating...
```

for several minutes.

Wait until Terraform shows either:

```text
Apply complete!
```

or a clear error message.

---

## Security Design

The project uses security groups to control traffic flow.

Typical traffic pattern:

```text
Internet
  → ALB security group allows HTTP on port 80
  → EC2 security group allows traffic only from the ALB security group
```

This means EC2 instances are not directly exposed to all inbound web traffic. Traffic should flow through the load balancer.

SSH access should remain disabled unless explicitly required for troubleshooting.

---

## Production Improvements

For a real production environment, I would improve this project by adding:

* HTTPS with ACM certificates
* Route 53 DNS record
* EC2 instances only in private subnets
* NAT Gateway or VPC endpoints for private outbound access
* AWS Systems Manager Session Manager instead of SSH
* Centralized logging
* ALB access logs to S3
* CloudWatch dashboards
* More CloudWatch alarms
* WAF in front of the ALB
* Remote Terraform state in S3 with DynamoDB locking
* Terraform modules split by environment
* GitHub Actions deployment with OIDC
* Blue-green or rolling deployment strategy
* Autoscaling policies based on CPU or request count

---

## Final Result

This project demonstrates practical AWS infrastructure design for Cloud Engineer, Platform Engineer and SRE roles. It shows that the environment can be provisioned from code, tested through an ALB endpoint, monitored with CloudWatch and safely destroyed after validation.
## Interview Talking Points
