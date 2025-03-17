variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for Terraform state storage"
  type        = string
  default     = "mysql-terraform-state-bucket"  # Change this to a unique name
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "terraform-lock-mysql"
}

variable "environment" {
  description = "Environment tag (e.g., Dev, Prod)"
  type        = string
  default     = "Dev"
}