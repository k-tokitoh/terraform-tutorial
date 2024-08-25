# これにより、モジュール利用者がこの値を参照できる
output "instance_id" {
  value = aws_instance.server.id
}
