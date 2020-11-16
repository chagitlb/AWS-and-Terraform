output "public_ips" {
  value = aws_instance.ec2[*].public_ip
}

output "private_ips" {
  value = aws_instance.ec2[*].private_ip
}

output "instance_id" {
    value = aws_instance.ec2[*].id
    description = "The ID of the instances"
}