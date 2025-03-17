#variables.tf (Define your variables)
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  default     = "ami-08b5b3a93ed654d19" # Amazon Linux 2 AMI
}
variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}
variable "key_name" {
  description = "EC2 key pair name"
  default     = "SQL"
}
variable "my_ip" {
  description = "Your public IP address"
  default     = "115.99.77.178"
}
variable "vpc_id" {
  description = "Your vpc_id"
  default     = "vpc-0e9693cfb9b9c6f31"
}
variable "mysql_username" {
  description = "MySQL admin username"
  type        = string
  default = "admin"
}
variable "secret_name" {
  description = "MySQL admin username"
  type        = string
  default = "mysql_password_setup"
}