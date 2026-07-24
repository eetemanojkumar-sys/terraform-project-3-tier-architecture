output "alb_dns_name" {
  description = "Public DNS name of the ALB - use this to access the app"
  value       = module.alb.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS connection endpoint (private, only reachable from app tier)"
  value       = module.rds.rds_endpoint
  sensitive   = true
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "asg_name" {
  value = module.ec2.asg_name
}
