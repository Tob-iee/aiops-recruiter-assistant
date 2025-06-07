# terraform/main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}


# ECR Repositories
data "aws_ecr_repository" "app" {
  name = "recruiter-assistant" #or var.app_name
}
# resource "aws_ecr_repository" "app" {
#   name                 = "${var.app_name}-app"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

# ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Task Definition
# resource "aws_ecs_task_definition" "app" {
#   family                   = var.app_name
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   cpu                      = "4096" # Adjust CPU as needed
#   memory                   = "8192" # Adjust memory as needed
#   execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
#   task_role_arn            = aws_iam_role.ecs_task_role.arn

#   container_definitions = jsonencode([
#     {
#       name  = "postgres"
#       image = "postgres:13"
#       essential = true
#       portMappings = [
#         {
#           containerPort = 5432
#           hostPort      = 5432
#           protocol      = "tcp"
#         }
#       ]
#       healthCheck = {
#         command     = ["CMD-SHELL", "pg_isready -U app_user -d recruiter_assistant"]
#         interval    = 30
#         timeout     = 5
#         retries     = 3
#         startPeriod = 60
#       }
#       environment = [
#         {
#           name  = "POSTGRES_DB"
#           value = "recruiter_assistant"
#         },
#         {
#           name  = "POSTGRES_USER"
#           value = "app_user"
#         },
#         {
#           name  = "PGDATA"
#           value = "/var/lib/postgresql/data/pgdata"
#         }
#       ]
#       secrets = [
#         {
#           name      = "POSTGRES_PASSWORD"
#           valueFrom = "${aws_secretsmanager_secret.app_secrets.arn}:POSTGRES_PASSWORD::"
#         }
#       ]

#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           "awslogs-group"         = "/ecs/${var.app_name}"
#           "awslogs-region"        = var.aws_region
#           "awslogs-stream-prefix" = "postgres"
#         }
#       }
#       mountPoints = [
#         {
#           sourceVolume  = "postgres_data"
#           containerPath = "/var/lib/postgresql/data"
#           readOnly      = false
#         }
#       ]
#     },
#     {
#       name  = "elasticsearch"
#       image = "docker.elastic.co/elasticsearch/elasticsearch:8.17.1"
#       essential = true
#       portMappings = [
#         {
#           containerPort = 9200
#           hostPort      = 9200
#           protocol      = "tcp"
#         }
#       ]
#       healthCheck = {
#         command     = ["CMD-SHELL", "curl -f http://localhost:9200/_cluster/health || exit 1"]
#         interval    = 30
#         timeout     = 5
#         retries     = 3
#         startPeriod = 120
#       }
#       environment = [
#         {
#           name  = "discovery.type"
#           value = "single-node"
#         },
#         {
#           name  = "xpack.security.enabled"
#           value = "false"
#         },
#         {
#           name  = "ES_JAVA_OPTS"
#           value = "-Xms1g -Xmx1g"
#         },
#         {
#           name  = "bootstrap.memory_lock"
#           value = "true"
#         }
#       ]
#       ulimits = [
#         {
#           name      = "nofile"
#           softLimit = 65536
#           hardLimit = 65536
#         },
#         {
#           name      = "memlock"
#           softLimit = -1
#           hardLimit = -1
#         }
#       ]
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           "awslogs-group"         = "/ecs/${var.app_name}"
#           "awslogs-region"        = var.aws_region
#           "awslogs-stream-prefix" = "elasticsearch"
#         }
#       }
#       mountPoints = [
#         {
#           sourceVolume  = "elasticsearch_data"
#           containerPath = "/usr/share/elasticsearch/data"
#           readOnly      = false
#         }
#       ]
#     },
#     {
#       name  = "web"
#       image = "${data.aws_ecr_repository.app.repository_url}:latest"
#       essential = true
#       dependsOn = [
#         {
#           containerName = "postgres"
#           condition     = "HEALTHY"
#         },
#         {
#           containerName = "elasticsearch"
#           condition     = "HEALTHY"
#         }
#       ]
#       portMappings = [
#         {
#           containerPort = var.container_port
#           hostPort      = var.container_port
#           protocol      = "tcp"
#         }
#       ]
#       healthCheck = {
#         command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}/healthz || exit 1"]
#         interval    = 30
#         timeout     = 5
#         retries     = 3
#         startPeriod = 60
#       }
#       environment = [
#         {
#           name  = "POSTGRES_HOST"
#           value = "localhost"
#         },
#         {
#           name  = "POSTGRES_DB"
#           value = "recruiter_assistant"
#         },
#         {
#           name  = "POSTGRES_USER"
#           value = "app_user"
#         },
#         {
#           name  = "ELASTIC_URL"
#           value = "http://localhost:9200"
#         }
#       ]
#       secrets = [
#         {
#           name      = "POSTGRES_PASSWORD"
#           valueFrom = "${aws_secretsmanager_secret.app_secrets.arn}:POSTGRES_PASSWORD::"
#         },
#         {
#           name      = "OPENAI_API_KEY"
#           valueFrom = "${aws_secretsmanager_secret.app_secrets.arn}:OPENAI_API_KEY::"
#         },
#         {
#           name      = "HF_API_KEY"
#           valueFrom = "${aws_secretsmanager_secret.app_secrets.arn}:HF_API_KEY::"
#         }
#       ]
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           "awslogs-group"         = "/ecs/${var.app_name}"
#           "awslogs-region"        = var.aws_region
#           "awslogs-stream-prefix" = "web"
#         }
#       }
#     }
#   ])

#   # Add volume definitions
#   volume {
#     name = "postgres_data"
#     efs_volume_configuration {
#       file_system_id          = aws_efs_file_system.persistent_data.id
#       root_directory          = "/"
#       transit_encryption      = "ENABLED"
#       transit_encryption_port = 2999
#       authorization_config {
#         access_point_id = aws_efs_access_point.postgres.id
#         iam             = "ENABLED"
#       }
#     }
#   }

#   volume {
#     name = "elasticsearch_data"
#     efs_volume_configuration {
#       file_system_id          = aws_efs_file_system.persistent_data.id
#       root_directory          = "/"
#       transit_encryption      = "ENABLED"
#       transit_encryption_port = 3000
#       authorization_config {
#         access_point_id = aws_efs_access_point.elasticsearch.id
#         iam             = "ENABLED"
#       }
#     }
#   }
# }
resource "aws_ecs_task_definition" "app" {
  family                   = var.app_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "4096"
  memory                   = "8192"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "postgres"
      image = "postgres:13"
      essential = true
      portMappings = [
        {
          containerPort = 5432
          protocol      = "tcp"
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "pg_isready -U app_user -d recruiter_assistant"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      environment = [
        {
          name  = "POSTGRES_DB"
          value = "recruiter_assistant"
        },
        {
          name  = "POSTGRES_USER"
          value = "app_user"
        },
        {
          name  = "PGDATA"
          value = "/var/lib/postgresql/data/pgdata"
        }
      ]
      secrets = [
        {
          name      = "POSTGRES_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.app_secrets.arn}:POSTGRES_PASSWORD::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.app_name}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "postgres"
        }
      }
      mountPoints = [
        {
          sourceVolume  = "postgres_data"
          containerPath = "/var/lib/postgresql/data"
          readOnly      = false
        }
      ]
    },
    {
      name  = "elasticsearch"
      image = "docker.elastic.co/elasticsearch/elasticsearch:8.17.1"
      essential = true
      portMappings = [
        {
          containerPort = 9200
          protocol      = "tcp"
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:9200/_cluster/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 120
      }
      environment = [
        {
          name  = "discovery.type"
          value = "single-node"
        },
        {
          name  = "xpack.security.enabled"
          value = "false"
        },
        {
          name  = "ES_JAVA_OPTS"
          value = "-Xms1g -Xmx1g"
        }
      ]
      ulimits = [
        {
          name      = "nofile"
          softLimit = 65536
          hardLimit = 65536
        },
        {
          name      = "memlock"
          softLimit = -1
          hardLimit = -1
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.app_name}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "elasticsearch"
        }
      }
      mountPoints = [
        {
          sourceVolume  = "elasticsearch_data"
          containerPath = "/usr/share/elasticsearch/data"
          readOnly      = false
        }
      ]
    },
    {
      name  = "web"
      image = "${data.aws_ecr_repository.app.repository_url}:latest"
      essential = true
      dependsOn = [
        {
          containerName = "postgres"
          condition     = "HEALTHY"
        },
        {
          containerName = "elasticsearch"
          condition     = "HEALTHY"
        }
      ]
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}/ || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 180
      }
      environment = [
        {
          name  = "POSTGRES_HOST"
          value = "localhost"
        },
        {
          name  = "POSTGRES_DB"
          value = "recruiter_assistant"
        },
        {
          name  = "POSTGRES_USER"
          value = "app_user"
        },
        {
          name  = "ELASTIC_URL"
          value = "http://localhost:9200"
        },
        {
          name  = "EMBEDDED_MODEL_NAME"
          value = "sentence-transformers/all-MiniLM-L6-v2"
        },
        {
          name  = "INDEX_NAME"
          value = "resume_index"
        },
        {
          name  = "S3_BUCKET_NAME"
          value = var.s3_bucket_name
        },
        {
          name  = "S3_PREFIX"
          value = var.s3_prefix
        },
        {
          name  = "AWS_DEFAULT_REGION"
          value = var.aws_region
        },
        {
          name  = "TRANSFORMERS_CACHE"
          value = "/app/.cache/huggingface"
        },
        {
          name  = "HF_HOME"
          value = "/app/.cache/huggingface"
        }
      ]
      secrets = [
        {
          name      = "POSTGRES_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.app_secrets.arn}:POSTGRES_PASSWORD::"
        },
        {
          name      = "OPENAI_API_KEY"
          valueFrom = "${aws_secretsmanager_secret.app_secrets.arn}:OPENAI_API_KEY::"
        },
        {
          name      = "HF_API_KEY"
          valueFrom = "${aws_secretsmanager_secret.app_secrets.arn}:HF_API_KEY::"
        },
        {
          name      = "AWS_ACCESS_KEY_ID"
          valueFrom = "${aws_secretsmanager_secret.app_secrets.arn}:AWS_ACCESS_KEY_ID::"
        },
        {
          name      = "AWS_SECRET_ACCESS_KEY"
          valueFrom = "${aws_secretsmanager_secret.app_secrets.arn}:AWS_SECRET_ACCESS_KEY::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.app_name}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "web"
        }
      }
    }
  ])

  # Volume definitions remain the same...
  volume {
    name = "postgres_data"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.persistent_data.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
      authorization_config {
        access_point_id = aws_efs_access_point.postgres.id
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "elasticsearch_data"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.persistent_data.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 3000
      authorization_config {
        access_point_id = aws_efs_access_point.elasticsearch.id
        iam             = "ENABLED"
      }
    }
  }
}

# Create EFS File System
resource "aws_efs_file_system" "persistent_data" {
  creation_token = "${var.app_name}-efs"
  encrypted      = true

  tags = {
    Name = "${var.app_name}-efs"
  }
}

# Create EFS Access Point for Postgres
resource "aws_efs_access_point" "postgres" {
  file_system_id = aws_efs_file_system.persistent_data.id

  posix_user {
    uid = 999
    gid = 999
  }

  root_directory {
    path = "/postgres"
    creation_info {
      owner_uid = 999
      owner_gid = 999
      permissions = "0777"
    }
  }
}

# Create EFS Access Point for Elasticsearch
resource "aws_efs_access_point" "elasticsearch" {
  file_system_id = aws_efs_file_system.persistent_data.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/elasticsearch"
    creation_info {
      owner_uid = 1000
      owner_gid = 1000
      permissions = "0755"
    }
  }
}

# Create EFS Mount Targets
resource "aws_efs_mount_target" "persistent_data" {
  count           = length(aws_subnet.ecs_private)
  
  file_system_id  = aws_efs_file_system.persistent_data.id
  # subnet_id       = module.vpc.private_subnets[count.index]
  subnet_id       = aws_subnet.ecs_private[count.index].id
  security_groups = [aws_security_group.efs.id]
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  # subnets           = module.vpc.public_subnets
  subnets            = aws_subnet.ecs_public[*].id
}

resource "aws_lb_target_group" "app" {
  name        = "${var.app_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  # vpc_id      = module.vpc.vpc_id
  vpc_id      = aws_vpc.ecs_vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200,302,404"  # Accept these status codes
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.ecs_private[*].id
    security_groups = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false  # Should be false for private subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "web"
    container_port   = var.container_port
  }
}

# Add CloudWatch Logs group
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 30
}

