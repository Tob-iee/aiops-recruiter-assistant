# terraform/variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "af-south-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# App specific variables
variable "app_name" {
  description = "Application name"
  type        = string
  default     = "recruiter-assistant"
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 8501
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
  default     = "recruiter-assistant-cluster"
}

# S3 Configuration
variable "s3_bucket_name" {
  description = "S3 bucket name for application data"
  type        = string
  default     = "aiops-recruiter-data"
}

variable "s3_prefix" {
  description = "S3 prefix for data files"
  type        = string
  default     = "rag-source-knowledge/"
}

#Specific variables in you terraform.tfvars locally for security 

variable "aws_access_key_id" {
  description = "AWS Access Key ID for S3 access"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key for S3 access"
  type        = string
  sensitive   = true
}
variable "openai_api_key" {
  description = "OpenAI API Key"
  type        = string
  sensitive   = true
}
variable "hf_api_key" {
  description = "Hugging Face API Key"
  type        = string
  sensitive   = true
}
