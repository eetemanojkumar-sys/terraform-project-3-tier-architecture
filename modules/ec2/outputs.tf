output "asg_name" {
  value = aws_autoscaling_group.app.name
}

output "ec2_sg_id" {
  value = aws_security_group.ec2.id
}

output "launch_template_id" {
  value = aws_launch_template.app.id
}
