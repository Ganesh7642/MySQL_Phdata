data "aws_iam_policy_document" "ec2_policy" {
    statement {
      effect = "Allow"
  
      actions = [
        "ec2:DescribeInstances",
        "ec2:DescribeVolumes",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ]
  
      resources = ["*"]
    }
  
    statement {
      effect = "Allow"
  
      actions = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:CreateSecret"
      ]
  
      resources = ["arn:aws:secretsmanager:us-east-1:302263086363:secret:my-db-secret-*"]
    }
  }
  