
# Create security group for EFS
resource "aws_security_group" "efs" {
  name        = "${var.app_name}-efs-sg"
  description = "Security group for EFS mount targets"
  # vpc_id      = module.vpc.vpc_id
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    description     = "NFS from ECS tasks"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }
}

# Security Groups
resource "aws_security_group" "alb" {
  name        = "${var.app_name}-alb-sg"
  description = "ALB Security Group"
  # vpc_id      = module.vpc.vpc_id
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.app_name}-ecs-tasks-sg"
  description = "ECS Tasks Security Group"
  # vpc_id      = module.vpc.vpc_id
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    protocol        = "tcp"
    # protocol        = "http"
    from_port       = var.container_port
    to_port         = var.container_port
    security_groups = [aws_security_group.alb.id]
  }
  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]  # Be more restrictive in production
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
