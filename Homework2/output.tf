output "web_server_public_address" {
    value = aws_instance.web.*.public_ip
}
output "db_nodes_private_addresses" {
    value = aws_instance.db.*.private_ip
}