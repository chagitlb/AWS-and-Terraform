output "public-ips" {
  value = module.public_servers.public_ips
}

output "private-ips" {
  value = module.private_servers.private_ips
}