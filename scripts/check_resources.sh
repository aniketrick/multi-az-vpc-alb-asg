#!/usr/bin/env bash
set -euo pipefail

echo "Checking AWS identity..."
aws sts get-caller-identity

echo "Checking project-tagged EC2 instances..."
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=multi-az-vpc-alb-asg" \
  --query "Reservations[].Instances[].[InstanceId,State.Name,InstanceType,PublicIpAddress,PrivateIpAddress]" \
  --output table

echo "Checking ALBs..."
aws elbv2 describe-load-balancers \
  --query "LoadBalancers[?contains(LoadBalancerName, 'multi-az-vpc')].[LoadBalancerName,State.Code,DNSName]" \
  --output table
