resource "aws_secretsmanager_secret" "mysql_secret" {
  name        = var.secret_name
  description = "MySQL database credentials"
}

resource "aws_secretsmanager_secret_version" "mysql_secret_value" {
  secret_id     = aws_secretsmanager_secret.mysql_secret.id
  secret_string = jsonencode({
    username = "admin",
    password = random_password.mysql.result
  })
}

resource "random_password" "mysql" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*()-_=+<>?"
}