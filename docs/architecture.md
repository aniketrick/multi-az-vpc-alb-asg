# Architecture Notes

## Design goal

The platform demonstrates a resilient AWS web architecture across two Availability Zones.

## Traffic flow

1. User sends HTTP request to the Application Load Balancer.
2. ALB listener receives traffic on port 80.
3. ALB forwards traffic to a target group.
4. Target group routes traffic to healthy EC2 instances managed by the Auto Scaling Group.
5. EC2 instances run a small Python web app installed through cloud-init/user_data.

## Public and private subnet design

The VPC includes public and private subnets across two AZs. The ALB is placed in public subnets because it must receive internet traffic. In a production version, EC2 instances should sit in private subnets and use NAT Gateway or VPC endpoints for outbound access.

For cost-safe testing, this project can run instances in public subnets by default when NAT Gateway is disabled, while still creating private subnets to demonstrate segmentation.

## NAT Gateway decision

NAT Gateway is intentionally disabled by default because it has an hourly charge and data processing charge. The Terraform variable `enable_nat_gateway` can be changed to true for a more production-like private-subnet deployment.

## High availability

The design spans two AZs. The ALB and ASG are configured with subnets in both AZs. If one instance fails, Auto Scaling replaces it. If one AZ has an issue, the design can continue serving from the other AZ, depending on desired capacity and healthy targets.

## Security groups

- ALB security group allows HTTP from the internet.
- EC2 security group only allows web traffic from the ALB security group.
- SSH is disabled by default.

## Observability

A CloudWatch CPU alarm is included as a basic operational signal. In a production design, this would be expanded with ALB 5XX errors, target response time, unhealthy target count and ASG capacity alarms.
