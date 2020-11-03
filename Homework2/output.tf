output "aws_instance_private_dns" {
    value = aws_instance.db.*.public_dns
}
output "aws_instance_public_dns" {
    value = aws_instance.web.*.public_dns
}