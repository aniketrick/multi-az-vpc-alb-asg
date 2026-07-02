# Interview Questions

## Beginner

1. What is a VPC?
2. What is a subnet?
3. What is an Availability Zone?
4. What is the difference between public and private subnets?
5. What is an Internet Gateway?
6. What is a route table?
7. What is a security group?
8. What is an Application Load Balancer?
9. What is an Auto Scaling Group?
10. Why use multiple Availability Zones?

## Intermediate

1. Explain the traffic flow from the internet to the EC2 app.
2. Why should the ALB be in public subnets?
3. Why should EC2 instances normally be in private subnets?
4. Why is NAT Gateway disabled by default here?
5. What is the role of a launch template?
6. How does the ALB know whether an instance is healthy?
7. How does Auto Scaling replace failed instances?
8. What is the difference between desired, minimum and maximum capacity?
9. How do security groups restrict access between ALB and EC2?
10. What would happen if one AZ fails?

## Advanced

1. How would you make this production-ready?
2. How would you add HTTPS with ACM?
3. How would you add Route 53 DNS?
4. How would you use private subnets without NAT Gateway?
5. When would you use VPC endpoints?
6. How would you reduce ALB and NAT costs?
7. How would you monitor target health and 5XX errors?
8. How would you implement blue-green deployment with ASGs?
9. How would you use Terraform remote state and state locking?
10. How would you design this across three AZs?
