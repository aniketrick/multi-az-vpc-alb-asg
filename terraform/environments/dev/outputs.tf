output "alb_dns_name" {
  description = "Application Load Balancer DNS name."
  value       = module.alb.alb_dns_name
}

output "target_group_arn" {
  description = "ALB target group ARN."
  value       = module.alb.target_group_arn
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name."
  value       = module.compute.autoscaling_group_name
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "cost_warning" {
  value = "ALB hours, public IPv4, EBS, data transfer and NAT Gateway if enabled may create charges. Destroy after testing."
}
