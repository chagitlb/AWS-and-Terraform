resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "terraform-key" {
  key_name   = "terraform-key1"
  public_key = tls_private_key.private_key.public_key_openssh
}
resource "local_file" "terraform_key" {
  sensitive_content  = tls_private_key.private_key.private_key_pem
  filename           = "private_key.pem"
}