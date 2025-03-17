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

    # Added the missing statement block for DynamoDB
    statement {
      effect = "Allow"

      actions = [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DeleteItem",
        "dynamodb:Scan",
        "dynamodb:UpdateItem"
      ]

      resources = ["arn:aws:dynamodb:us-east-1:302263086363:table/terraform-lock-mysql"]
    }
}
resource "aws_iam_policy_attachment" "ec2_role_ssm_full_access" {
  name       = "ec2-role-ssm-full-access-attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}
