provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "mysql-terraform-state-bucket"  # Use the same name as in variable.tf
    key            = "terraform.tfstate"            # Path to store the state file
    region         = "us-east-1"
    encrypt        = true
    use_lockfile = true                           # New way to enable DynamoDB locking
  }
}

# Security group to allow SSH access
resource "aws_security_group" "allow_ssh" {
  name        = "allow-ssh"
  description = "Allow SSH access only from my IP"
  vpc_id      = var.vpc_id # Ensure you specify the correct VPC ID

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"] # Use your public IP
  }
  ingress {
    from_port   = 3307
    to_port     = 3307
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"] # Allow access to MySQL on port 3307 from your IP
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    prevent_destroy = false # Prevent security group from being destroyed, thus preventing EC2 instance recreation
  }
}

# IAM role for EC2 instance profile
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach necessary policies to the IAM role
resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2-policy"
  description = "EC2 and Secrets Manager policy"
  policy      = data.aws_iam_policy_document.ec2_policy.json
}
resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}
# Create an IAM instance profile to attach to the EC2 instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Create a KMS Key for EBS encryption
resource "aws_kms_key" "ebs_kms_key" {
  description             = "KMS key for EBS volume encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = {
    Name = "EBS-KMS-Key"
  }
}

# EC2 instance with role, subnet, and block device (with KMS encryption)
resource "aws_instance" "mysql_instance" {
  ami                                  = var.ami_id
  instance_type                        = var.instance_type
  key_name                             = var.key_name
  security_groups                      = [aws_security_group.allow_ssh.name]
  associate_public_ip_address          = true
  iam_instance_profile                 = aws_iam_instance_profile.ec2_instance_profile.name
  instance_initiated_shutdown_behavior = "stop" # Corrected attribute
  disable_api_termination              = true   # Disable API termination
  tags = {
    Name = "MySQL-Instance"
  }

  # Block device (20GB EBS volume with KMS encryption)
  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    encrypted   = true 
    kms_key_id  = aws_kms_key.ebs_kms_key.arn # Attach KMS key for encryption
  }

  # User data to install and configure MySQL
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum remove -y mysql57-community-release || true
    sudo rpm -Uvh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
    sudo rm -f /etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
    sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
    sudo yum clean all
    sudo yum install -y mysql-community-server
    sudo systemctl start mysqld
    sudo systemctl enable mysqld
    echo -e "\n[mysqld]\nport=3307" | sudo tee -a /etc/my.cnf
    sudo wget https://github.com/datacharmer/test_db/archive/refs/heads/master.zip
    sudo yum install -y unzip
    sudo unzip master.zip
  EOF
  lifecycle {
    prevent_destroy = false # Prevent the instance from being destroyed
  }
}


