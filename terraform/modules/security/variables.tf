variable "name" { type = string }
variable "vpc_id" { type = string }
variable "app_port" { type = number }
variable "enable_ssh" { type = bool }
variable "ssh_cidr" { type = string }
variable "tags" { type = map(string) }
