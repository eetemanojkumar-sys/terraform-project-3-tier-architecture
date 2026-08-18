resource "aws_iam_role" "ssm" {
  name = "${var.project_name}-${var.environment}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-ssm-role"
    Environment = var.environment
  }
}


resource "aws_iam_role_policy_attachment" "ssm" {
  role = aws_iam_role.ssm.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "ssm" {
  name = "${var.project_name}-${var.environment}-ec2-ssm-profile"

  role = aws_iam_role.ssm.name
}
