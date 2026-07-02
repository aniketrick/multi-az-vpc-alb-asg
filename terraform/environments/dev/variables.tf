variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-west-2"
}

variable "name" {
  description = "Project resource name prefix."
  type        = string
  default     = "multi-az-vpc"
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.40.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to use."
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "EC2 instance type. t2.micro is free-tier eligible for legacy free-tier accounts."
  type        = string
  default     = "t2.micro"
}

variable "app_port" {
  description = "Port used by the demo app."
  type        = number
  default     = 8080
}

variable "desired_capacity" {
  description = "Desired EC2 instance count. Keep 1 for cost-conscious testing."
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum EC2 instance count."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum EC2 instance count."
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet outbound internet. Disabled by default because NAT Gateway is billable."
  type        = bool
  default     = false
}

variable "place_instances_in_private_subnets" {
  description = "Place app instances in private subnets. Requires NAT Gateway or a custom AMI with app dependencies already available. Disabled by default for cost-safe testing."
  type        = bool
  default     = false
}

variable "enable_ssh" {
  description = "Enable SSH ingress to instances. Disabled by default."
  type        = bool
  default     = false
}

variable "ssh_cidr" {
  description = "CIDR allowed for SSH if enable_ssh is true."
  type        = string
  default     = "0.0.0.0/0"
}
