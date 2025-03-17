output "mysql_password" {
  value     = random_password.mysql.result
  sensitive = true
}