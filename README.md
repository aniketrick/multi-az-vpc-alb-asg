# Multi-AZ VPC with a Load Balancer and Auto Scaling

A small web app running on AWS across two Availability Zones, built with Terraform. It has a custom VPC, an Application Load Balancer, an Auto Scaling Group of EC2 instances, and a CloudWatch alarm. The Terraform is split into four modules: network, security, alb and compute.

I built it to understand how traffic actually gets from the internet to a server in AWS, and what keeps the app up when one instance or one Availability Zone fails.

## How it works

```text
Internet
   │  HTTP :80
   ▼
Application Load Balancer (public subnets in 2 AZs)
   │  :8080, health check: HTTP GET / must return 200
   ▼
Target group
   ▼
Auto Scaling Group (launch template, ELB health checks)
   └── EC2 instances running a small Python web server
```

## Design choices

- **Two Availability Zones**, each with one public and one private subnet.
- **The app instances only accept traffic from the load balancer.** Their security group allows port 8080 from the ALB's security group and nothing else. SSH is off unless you turn it on.
- **The Auto Scaling Group uses ELB health checks.** If the load balancer marks an instance unhealthy, the group replaces it.
- **No NAT Gateway by default**, because it's charged by the hour. That means the instances run in the **public subnets** by default, so they can install the app when they start. You can move them to the private subnets with `place_instances_in_private_subnets = true` and `enable_nat_gateway = true`.
- **A CloudWatch alarm** goes off when average CPU across the group is above 70% for two minutes.

## CI

GitHub Actions runs `terraform fmt`, `init` and `validate` on every push and pull request.

## Run it yourself

You'll need the AWS CLI and Terraform. I tested it in `eu-west-2`.

```bash
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply

# Check the app and the target health
curl http://$(terraform output -raw alb_dns_name)
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw target_group_arn)

# Clean up. The ALB is charged by the hour.
terraform destroy
```

## Not done yet

- **The CPU alarm doesn't trigger anything yet.** Next I'll add a target tracking scaling policy and an SNS email alert.
- **Private subnets by default.** I want to run the app instances in the private subnets, using VPC endpoints or a pre-built AMI instead of a NAT Gateway.
- **HTTPS** on the load balancer, with a certificate from ACM.
- **Shared Terraform state** in S3 with locking.
