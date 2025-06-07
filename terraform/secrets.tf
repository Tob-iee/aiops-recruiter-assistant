# terraform/secrets.tf

# Create random passwords for database and API keys
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Create the secrets manager secret with recovery configuration
resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "${var.app_name}-secrets"
  description            = "Application secrets for ${var.app_name}"
  recovery_window_in_days = 0  # Immediate deletion, no recovery window
  
  lifecycle {
    ignore_changes = [
      recovery_window_in_days
    ]
  }
}

# Create the initial secret version with all required secrets
resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    POSTGRES_DB           = "recruiter_assistant"
    POSTGRES_USER         = "app_user"
    POSTGRES_PASSWORD     = random_password.db_password.result
    OPENAI_API_KEY        = var.openai_api_key
    HF_API_KEY            = var.hf_api_key
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
  })

  lifecycle {
    ignore_changes = [
      secret_string  # Ignore changes to prevent overwriting manually updated values
    ]
  }
}

# IAM policy for ECS to access secrets
resource "aws_iam_policy" "secrets_access" {
  name = "${var.app_name}-secrets-access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [aws_secretsmanager_secret.app_secrets.arn]
      }
    ]
  })
}

# Attach the secrets policy to the ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_secrets" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

