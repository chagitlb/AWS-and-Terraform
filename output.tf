output "ansible_server_public_address" {
    value = aws_instance.web.*.public_ip
}